# frozen_string_literal: true

module LinkedRails
  class IRIMapper
    class << self
      EMPTY_IRI_OPTS = {params: {}}.freeze

      # Converts an IRI into a hash containing the action, class, iri and the params of the iri
      # @return [Hash]
      # @example Valid resource IRI
      #   opts_from_iri('https://example.com/resource/1?foo=bar')
      #   => {
      #     action: 'show',
      #     class: Resource,
      #     params: {
      #       id: '1',
      #       foo: 'bar'
      #     }
      #   }
      # @example Valid collection IRI
      #   opts_from_iri('https://example.com/resources?foo=bar')
      #   => {
      #     action: 'index',
      #     class: Resource,
      #     params: {
      #       foo: 'bar'
      #     }
      #   }
      # @example Invalid IRI
      #   opts_from_iri('https://example.com/invalid/1')
      #   => {
      #     params: {}
      #   }
      def opts_from_iri(iri, method: 'GET')
        query = Rack::Utils.parse_nested_query(URI(iri.to_s).query)
        params = Rails.application.routes.recognize_path(iri.to_s, method: method)

        route_params_to_opts(params.merge(query))
      rescue ActionController::RoutingError
        EMPTY_IRI_OPTS.dup
      end

      def index_resource_from_iri(iri, user_context)
        ensure_absolute_iri!(iri)

        opts = opts_from_iri(iri)
        index_resource_from_opts(opts, user_context)
      end

      def index_resource_from_iri!(iri, user_context)
        index_resource_from_iri(iri, user_context) || raise(ActiveRecord::RecordNotFound)
      end

      def index_resource_from_opts(opts, user_context)
        opts[:class]&.requested_index_resource(opts[:params], user_context) if opts[:action] == 'index'
      end

      def parent_from_params(params, user_context)
        return unless params.key?(:parent_iri)

        parent_iri = "/#{params[:parent_iri]}"
        opts = LinkedRails.iri_mapper.opts_from_iri(parent_iri)
        opts[:params] = params.except(:parent_iri, :singular_route).merge(opts[:params])

        LinkedRails.iri_mapper.resource_from_opts(opts, user_context)
      end

      def resource_from_iri(iri, user_context)
        ensure_absolute_iri!(iri)

        opts = opts_from_iri(iri)
        resource_from_opts(opts, user_context)
      end

      def resource_from_iri!(iri, user_context)
        resource_from_iri(iri, user_context) || raise(ActiveRecord::RecordNotFound)
      end

      def resource_from_opts(opts, user_context)
        opts[:class]&.requested_resource(opts, user_context)
      end

      def route_params_to_opts(params)
        controller_class = class_for_controller(params[:controller])

        return EMPTY_IRI_OPTS.dup if controller_class.blank?

        {
          action: params[:action],
          class: controller_class,
          params: params.except(:action, :controller)
        }.with_indifferent_access
      end

      def single_resource_from_iri(iri, user_context)
        ensure_absolute_iri!(iri)

        opts = opts_from_iri(iri)
        single_resource_from_opts(opts, user_context)
      end

      def single_resource_from_iri!(iri, user_context)
        single_resource_from_iri(iri, user_context) || raise(ActiveRecord::RecordNotFound)
      end

      def single_resource_from_opts(opts, user_context)
        opts[:class]&.requested_single_resource(opts[:params], user_context) unless opts[:params] == 'index'
      end

      private

      def class_for_controller(controller)
        return if controller.blank?

        controller.classify.safe_constantize ||
          "::#{controller.camelize}Controller"
            .safe_constantize
            .try(:controller_class)
      end

      def ensure_absolute_iri!(iri)
        raise("An absolute url is expected. #{iri} is given.") if iri.blank? || URI(iri).relative?
      end
    end
  end
end
