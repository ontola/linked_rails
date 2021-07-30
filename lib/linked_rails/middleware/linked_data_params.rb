# frozen_string_literal: true

module LinkedRails
  module Middleware
    class LinkedDataParams
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

      def add_param_from_query(data, target_class, key, value)
        data[target_class.predicate_mapping[RDF::URI(key)].key] = value
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

      def graph_from_request(request)
        request_graph = request.delete_param("<#{Vocab.ll[:graph].value}>")
        return if request_graph.blank?

        RDF::Graph.load(
          request_graph[:tempfile].path,
          content_type: request_graph[:type],
          canonicalize: true,
          intern: false
        )
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

        request.update_param(:body_graph, graph)
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

      def target_class_from_path(request) # rubocop:disable Metrics/AbcSize
        opts = LinkedRails.iri_mapper.opts_from_iri(
          request.base_url + request.env['REQUEST_URI'],
          method: request.request_method
        )

        Rails.logger.info("No class found for #{request.base_url + request.env['REQUEST_URI']}") unless opts[:class]

        opts[:class]
      end

      def update_actor_param(request, graph)
        actor = graph.query([Vocab.ll[:targetResource], Vocab.schema.creator]).first
        return if actor.blank?

        request.update_param(:actor_iri, actor.object)
        graph.delete(actor)
      end

      def update_target_params(request, graph, target_class)
        key = target_class.to_s.demodulize.underscore

        parser = ParamsParser.new(graph: graph, params: request.params)
        from_body = parser.parse_resource(Vocab.ll[:targetResource], target_class)

        request.update_param(key, from_body.merge(request.params[key] || {}))
      end
    end
  end
end
