# frozen_string_literal: true

module LinkedRails
  module Middleware
    class LinkedDataParams # rubocop:disable Metrics/ClassLength
      def initialize(app)
        @app = app
      end

      def call(env)
        req = Rack::Request.new(env)
        params_from_query(req)
        params_from_graph(req)

        @app.call(env)
      end

      private

      def add_param(hash, key, value) # rubocop:disable Metrics/MethodLength
        case hash[key]
        when nil
          hash[key] = value
        when Hash
          hash[key].merge!(value)
        when Array
          hash[key].append(value)
        else
          hash[key] = [hash[key], value]
        end
        hash
      end

      def associated_class_from_params(reflection, graph, subject)
        return reflection.klass unless reflection.polymorphic?

        query = graph.query(subject: subject, predicate: NS::RDFV[:type])
        if query.empty?
          raise("No type given for '#{subject}' referenced by polymorphic association '#{reflection.name}'")
        end

        iri_to_class(query.first.object)
      end

      def blob_attribute(base_params, value)
        base_params["<#{value}>"] if value.starts_with?(Vocab::LL['blobs/'])
      end

      def convert_query_params(request, target_class)
        keys = target_class.predicate_mapping.keys.map(&:to_s)
        class_key = target_class.to_s.underscore
        data = request.params[class_key] || {}
        request.params.slice(*keys.map(&:to_s)).each do |key, value|
          add_param_from_query(data, target_class, key, value)
        end
        request.update_param(class_key, data) if data.present?
      end

      def add_param_from_query(data, target_class, key, value)
        data[target_class.predicate_mapping[RDF::URI(key)].key] = value
      end

      def enum_attribute(klass, key, value)
        opts = RDF::Serializers.serializer_for(klass).try(:enum_options, key)
        return if opts.blank?

        opts.detect { |_k, options| options.iri == value }&.first&.to_s
      end

      def graph_from_request(request)
        request_graph = request.delete_param("<#{Vocab::LL[:graph].value}>")
        return if request_graph.blank?

        RDF::Graph.load(
          request_graph[:tempfile].path,
          content_type: request_graph[:type],
          canonicalize: true,
          intern: false
        )
      end

      def iri_to_class(iri)
        iri.to_s.split(LinkedRails.app_ns.to_s).pop&.classify&.safe_constantize ||
          ApplicationRecord.descendants.detect { |klass| klass.iri == iri }
      end

      def logger
        Rails.logger
      end

      def nested_attributes(base_params, graph, subject, klass, association, collection) # rubocop:disable Metrics/ParameterLists
        nested_resources =
          if graph.query([subject, RDF::RDFV[:first], nil]).present?
            nested_attributes_from_list(base_params, graph, subject, klass)
          else
            parsed = parse_nested_resource(base_params, graph, subject, klass)
            collection ? {rand(1_000_000_000).to_s => parsed} : parsed
          end
        ["#{association}_attributes", nested_resources]
      end

      def nested_attributes_from_list(base_params, graph, subject, klass)
        Hash[
          RDF::List.new(subject: subject, graph: graph)
            .map { |nested| [rand(1_000_000_000).to_s, parse_nested_resource(base_params, graph, nested, klass)] }
        ]
      end

      # Converts a serialized graph from a multipart request body to a nested
      # attributes hash.
      #
      # The graph sent to the server should be sent under the `ll:graph` form name.
      # The entrypoint for the graph is the `ll:targetResource` subject, which is
      # assumed to be the resource intended to be targeted by the request (i.e. the
      # resource to be created, updated, or deleted).
      #
      # @return [Hash] A hash of attributes, empty if no statements were given.
      def params_from_graph(request)
        graph = graph_from_request(request)

        return unless graph

        target_class = target_class_from_path(request)
        return if target_class.blank?

        update_actor_param(request, graph)
        update_target_params(request, graph, target_class)
      end

      def params_from_query(request)
        target_class = target_class_from_path(request) if request.params.present?
        return unless target_class.try(:predicate_mapping)

        convert_query_params(request, target_class)
      end

      def parse_nested_resource(base_params, graph, subject, klass)
        resource = parse_resource(base_params, graph, subject, klass)
        resource[:id] ||= LinkedRails.iri_mapper.opts_from_iri(subject)[:params][:id] if subject.iri?
        resource
      end

      # Recursively parses a resource from graph
      def parse_resource(base_params, graph, subject, klass)
        graph
          .query([subject])
          .map { |statement| parse_statement(base_params, graph, statement, klass) }
          .compact
          .reduce({}) { |h, (k, v)| add_param(h, k, v) }
      end

      def parse_statement(base_params, graph, statement, klass)
        field = serializer_field(klass, statement.predicate)
        if field.is_a?(FastJsonapi::Attribute)
          parsed_attribute(base_params, klass, field.key, statement.object.value)
        elsif field.is_a?(FastJsonapi::Relationship)
          parsed_association(base_params, graph, statement.object, klass, field.association || field.key)
        end
      end

      def parsed_association(base_params, graph, object, klass, association)
        reflection = klass.reflect_on_association(association) || raise("#{association} not found for #{klass}")

        if graph.has_subject?(object)
          association_klass = associated_class_from_params(reflection, graph, object)
          nested_attributes(base_params, graph, object, association_klass, association, reflection.collection?)
        elsif object.iri?
          attributes_from_iri(object, association, reflection)
        end
      end

      def attributes_from_iri(object, association, reflection)
        if reflection.options[:through]
          key = reflection.has_one? ? "#{association}_id" : "#{association.to_s.singularize}_ids"
        elsif reflection.belongs_to?
          key = reflection.foreign_key
        end
        return unless key

        resource = LinkedRails.iri_mapper.resource_from_iri(object, nil)
        value = resource&.send(reflection.association_primary_key)

        [key, value] if value
      end

      def parsed_attribute(base_params, klass, key, value)
        [key, blob_attribute(base_params, value) || enum_attribute(klass, key, value) || value]
      end

      def serializer_field(klass, predicate)
        field = klass.try(:predicate_mapping).try(:[], predicate)
        logger.info("#{predicate} not found for #{klass || 'nil'}") if field.blank?
        field
      end

      def target_class_from_path(request) # rubocop:disable Metrics/AbcSize
        opts = LinkedRails.iri_mapper.opts_from_iri(
          request.base_url + request.env['REQUEST_URI'],
          method: request.request_method
        )

        logger.info("No class found for #{request.base_url + request.env['REQUEST_URI']}") unless opts[:class]

        opts[:class]
      end

      def update_actor_param(request, graph)
        actor = graph.query([Vocab::LL[:targetResource], RDF::Vocab::SCHEMA.creator]).first
        return if actor.blank?

        request.update_param(:actor_iri, actor.object)
        graph.delete(actor)
      end

      def update_target_params(request, graph, target_class)
        request.update_param(
          target_class.to_s.demodulize.underscore,
          parse_resource(request.params, graph, Vocab::LL[:targetResource], target_class)
        )
      end
    end
  end
end
