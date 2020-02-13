# frozen_string_literal: true

module LinkedRails
  module Middleware
    class LinkedDataParams # rubocop:disable Metrics/ClassLength
      attr_reader :graph, :request

      def initialize(app)
        @app = app
      end

      def call(env)
        @request = Rack::Request.new(env)
        params_from_graph
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

      def base_params
        request.params
      end

      def blob_attribute(value)
        base_params["<#{value}>"] if value.starts_with?(Vocab::LL['blobs/'])
      end

      def enum_attribute(klass, key, value)
        opts = ActiveModel::Serializer.serializer_for(klass).try(:enum_options, key)
        return if opts.blank?

        opts[:options].detect { |_k, options| options[:iri] == value }&.first
      end

      def graph_from_request
        request_graph = request.delete_param("<#{Vocab::LL[:graph].value}>")
        return if request_graph.blank?

        RDF::Graph.load(
          request_graph[:tempfile].path,
          content_type: request_graph[:type],
          canonicalize: true,
          intern: false
        )
      end

      def logger
        Rails.logger
      end

      def nested_attributes(subject, klass, association, collection)
        nested_resources =
          if graph.query([subject, RDF::RDFV[:first], nil]).present?
            nested_attributes_from_list(subject, klass)
          else
            parsed = parse_nested_resource(subject, klass)
            collection ? {rand(1_000_000_000).to_s => parsed} : parsed
          end
        ["#{association}_attributes", nested_resources]
      end

      def nested_attributes_from_list(subject, klass)
        Hash[
          RDF::List.new(subject: subject, graph: graph)
            .map { |nested| [rand(1_000_000_000).to_s, parse_nested_resource(nested, klass)] }
        ]
      end

      def opts_from_route(route, method = 'GET', klass: nil)
        opts = Rails.application.routes.recognize_path(route, method: method)
        route_klass = opts[:controller]&.classify&.safe_constantize
        return {} unless klass.nil? || route_klass.present? && klass <=> route_klass

        opts
      rescue ActionController::RoutingError
        {}
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
      def params_from_graph
        @graph = graph_from_request

        target_class = graph && target_class_from_path
        if target_class.blank?
          logger.info("No class found for #{request.env['PATH_INFO']}") if graph
          return
        end

        update_actor_param
        update_target_params(target_class)
      end

      def parse_nested_resource(subject, klass)
        resource = parse_resource(subject, klass)
        resource[:id] ||= opts_from_route(subject.to_s, klass: klass)[:id]
        resource
      end

      # Recursively parses a resource from graph
      def parse_resource(subject, klass)
        graph
          .query([subject])
          .map { |statement| parse_statement(statement, klass) }
          .compact
          .reduce({}) { |h, (k, v)| add_param(h, k, v) }
      end

      def parse_statement(statement, klass)
        field = serializer_field(klass, statement.predicate)
        if field.is_a?(ActiveModel::Serializer::Attribute)
          parsed_attribute(klass, field.name, statement.object.value)
        elsif field.is_a?(ActiveModel::Serializer::Reflection)
          parsed_association(statement.object, klass, field.options[:association] || field.name)
        end
      end

      def parsed_association(object, klass, association)
        reflection = klass.reflect_on_association(association)
        raise "Association #{association} not found for #{klass}" if reflection.blank?

        association_klass = reflection.klass
        if graph.has_subject?(object)
          nested_attributes(object, association_klass, association, reflection.collection?)
        elsif object.iri?
          ["#{association}_id", opts_from_route(object.to_s, klass: association_klass)[:id]]
        end
      end

      def parsed_attribute(klass, key, value)
        [key, blob_attribute(value) || enum_attribute(klass, key, value) || value]
      end

      def serializer_field(klass, predicate)
        field = klass.try(:predicate_mapping).try(:[], predicate)
        logger.info("#{predicate} not found for #{klass}") if field.blank?
        field
      end

      def target_class_from_path
        opts = opts_from_route(request.env['PATH_INFO'], request.request_method)
        return if opts.blank?

        controller = "#{opts[:controller]}_controller".classify.constantize
        controller.try(:controller_class) || controller.controller_name.classify.safe_constantize
      end

      def update_actor_param
        actor = graph.query([Vocab::LL[:targetResource], RDF::Vocab::SCHEMA.creator]).first
        return if actor.blank?

        request.update_param(:actor_iri, actor.object)
        graph.delete(actor)
      end

      def update_target_params(target_class)
        request.update_param(
          target_class.to_s.underscore,
          parse_resource(Vocab::LL[:targetResource], target_class)
        )
      end
    end
  end
end
