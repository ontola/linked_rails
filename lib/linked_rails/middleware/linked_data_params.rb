# frozen_string_literal: true

module LinkedRails
  module Middleware
    class LinkedDataParams # rubocop:disable Metrics/ClassLength
      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        params_from_graph(request)
        @app.call(env)
      end

      private

      def blob_attribute(base_params, value)
        base_params["<#{value}>"] if value.starts_with?(NS::LL['blobs/'])
      end

      def enum_attribute(klass, key, value)
        opts = ActiveModel::Serializer.serializer_for(klass).try(:enum_options, key)
        return if opts.blank?

        opts[:options].detect { |_k, options| options[:iri] == value }&.first
      end

      def graph_from_request(request)
        request_graph = request.delete_param("<#{NS::LL[:graph].value}>")
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

      def nested_attributes(graph, subject, klass, association, base_params)
        nested_resources =
          if graph.query([subject, NS::RDFV[:first], nil]).present?
            RDF::List.new(subject: subject, graph: graph)
              .map { |nested| parse_nested_resource(graph, nested, klass, base_params) }
          else
            parse_nested_resource(graph, subject, klass, base_params)
          end
        ["#{association}_attributes", nested_resources]
      end

      def opts_from_route(route, method = 'GET', klass: nil)
        opts = Rails.application.routes.recognize_path(route, method: method)
        route_klass = opts[:controller]&.classify&.safe_constantize
        return {} unless klass.nil? || route_klass.present? && klass <= route_klass

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
      def params_from_graph(request)
        graph = graph_from_request(request)
        target_class = graph && target_class_from_path(request.env['PATH_INFO'], request.request_method)
        if target_class.blank?
          logger.info("No class found for #{request.env['PATH_INFO']}") if graph
          return
        end

        set_actor_param(request, graph)
        set_target_params(request, graph, target_class)
      end

      def parse_nested_resource(graph, subject, klass, base_params)
        resource = parse_resource(graph, subject, klass, base_params)
        resource[:id] ||= opts_from_route(subject.to_s, klass: klass)[:id]
        resource
      end

      # Recursively parses a resource from graph
      def parse_resource(graph, subject, klass, base_params)
        HashWithIndifferentAccess[
          graph
            .query([subject])
            .map { |statement| parse_statement(graph, statement, klass, base_params) }
            .compact
        ]
      end

      def parse_statement(graph, statement, klass, base_params)
        field = serializer_field(klass, statement.predicate)
        if field.is_a?(ActiveModel::Serializer::Attribute)
          parsed_attribute(klass, field.name, statement.object.value, base_params)
        elsif field.is_a?(ActiveModel::Serializer::Reflection)
          parsed_association(graph, statement.object, klass, field.options[:association] || field.name, base_params)
        end
      end

      def parsed_association(graph, object, klass, association, base_params)
        association_klass = klass.reflect_on_association(association).klass
        if graph.has_subject?(object)
          nested_attributes(graph, object, association_klass, association, base_params)
        elsif object.iri?
          ["#{association}_id", opts_from_route(object.to_s, klass: association_klass)[:id]]
        end
      end

      def parsed_attribute(klass, key, value, base_params)
        [key, blob_attribute(base_params, value) || enum_attribute(klass, key, value) || value]
      end

      def serializer_field(klass, predicate)
        field = klass.try(:predicate_mapping).try(:[], predicate)
        logger.info("#{predicate} not found for #{klass}") if field.blank?
        field
      end

      def set_actor_param(request, graph)
        actor = graph.query([NS::LL[:targetResource], NS::SCHEMA[:creator]]).first
        return if actor.blank?

        request.update_param(:actor_iri, actor.object)
        graph.delete(actor)
      end

      def set_target_params(request, graph, target_class)
        request.update_param(
          target_class.to_s.underscore,
          parse_resource(graph, NS::LL[:targetResource], target_class, request.params)
        )
      end

      def target_class_from_path(path, method)
        opts = opts_from_route(path, method)
        return if opts.blank?

        controller = "#{opts[:controller]}_controller".classify.constantize
        controller.try(:controller_class) || controller.controller_name.classify.safe_constantize
      end
    end
  end
end
