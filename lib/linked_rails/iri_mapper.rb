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
      #     iri: 'https://example.com/resource/1?foo=bar',
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
      #     iri: 'https://example.com/resources?foo=bar',
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

        route_params_to_opts(params.merge(query), iri.to_s)
      rescue ActionController::RoutingError, SystemStackError
        EMPTY_IRI_OPTS.dup
      end

      def parent_from_params(params, user_context)
        return unless params.key?(:parent_iri)

        parent_iri = LinkedRails.iri(path: "/#{params[:parent_iri]}")

        LinkedRails.iri_mapper.resource_from_iri(parent_iri, user_context)
      end

      def resource_from_iri(iri, user_context)
        return nil unless absolute_iri?(iri)

        opts = opts_from_iri(iri)
        resource_from_opts(opts, user_context)
      end

      def resource_from_iri!(iri, user_context)
        resource_from_iri(iri, user_context) || raise(ActiveRecord::RecordNotFound)
      end

      def resource_from_opts(opts, user_context)
        opts[:class]&.requested_resource(opts, user_context)
      end

      def route_params_to_opts(params, iri)
        controller_class = class_for_controller(params[:controller])

        return EMPTY_IRI_OPTS.dup if controller_class.blank?

        {
          action: params[:action],
          class: controller_class,
          iri: iri,
          params: sanitized_route_params(controller_class, params)
        }.with_indifferent_access
      end

      private

      def absolute_iri?(iri)
        iri.present? && !URI(iri).relative?
      end

      def class_for_controller(controller)
        return if controller.blank?

        "::#{controller.camelize}Controller"
          .safe_constantize
          .try(:controller_class)
      end

      def sanitized_route_params(controller_class, params)
        new_params = params.except(:action, :controller)
        nested_key = :"#{controller_class.name.tableize.singularize}_id"
        new_params[:id] ||= new_params.delete(nested_key) if new_params.key?(nested_key)
        new_params
      end
    end
  end
end
