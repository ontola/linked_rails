# frozen_string_literal: true

module LinkedRails
  module IRIMapper
    class << self
      # Converts an IRI into a hash containing the type and id of the resource
      # @return [Hash] The id and type of the resource, or nil if the IRI is not found
      # @example Valid IRI
      #   opts_from_iri('https://example.com/resource/1')
      #   => {action: 'show', type: 'resource', id: '1'}
      # @example Invalid IRI
      #   opts_from_iri('https://example.com/invalid/1')
      #   => {}
      # @example Nil IRI
      #   opts_from_iri(nil)
      #   => {}
      def opts_from_iri(iri, method: 'GET')
        opts = Rails.application.routes.recognize_path(iri.to_s, method: method)

        return {} unless opts[:id].present? && opts[:controller].present?

        opts[:type] = opts[:controller].singularize
        opts
      rescue ActionController::RoutingError
        {}
      end

      # @return [ApplicationRecord, nil] The resource corresponding to the iri, or nil if the IRI is not found
      def resource_from_iri(iri)
        raise "A full url is expected. #{iri} is given." if iri.blank? || URI(iri).relative?

        opts = opts_from_iri(iri)
        resource_from_opts(opts) if resource_action?(opts[:action])
      end

      def resource_from_iri!(iri)
        resource_from_iri(iri) || raise(ActiveRecord::RecordNotFound)
      end

      def resource_from_opts(opts)
        opts[:class] ||= ApplicationRecord.descendants.detect { |m| m.to_s == opts[:type].classify } if opts[:type]
        return if opts[:class].blank? || opts[:id].blank?

        opts[:class]&.find_by(id: opts[:id])
      end

      private

      def resource_action?(action)
        %w[show update destroy].include?(action)
      end
    end
  end
end
