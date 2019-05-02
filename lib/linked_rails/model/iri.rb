# frozen_string_literal: true

module LinkedRails
  module Model
    module Iri
      extend ActiveSupport::Concern

      # @return [RDF::URI].
      def iri(opts = {})
        if opts.blank?
          @iri ||= iri_from_path(iri_path)
        else
          iri_from_path(URI(iri_path).path, opts)
        end
      end

      def iri_from_path(path, opts = {})
        uri_opts = {scheme: LinkedRails.scheme, host: LinkedRails.host, path: path}
        uri_opts[:fragment] = opts[:fragment] if opts[:fragment].present?
        uri_opts[:query] = opts.except(:fragment).to_param if opts.except(:fragment).present?
        RDF::URI(uri_opts)
      end

      # @return [String]
      def iri_path(_opts = nil)
        ["/#{[route_key, to_param].compact.join('/')}", route_fragment].compact.join('#')
      end

      def reload(_opts = {})
        @iri = nil
        super
      end

      def route_fragment; end

      def route_key
        self.class.route_key
      end

      module ClassMethods
        def iri
          @iri ||= iri_namespace[name.demodulize]
        end

        def iri_namespace
          superclass.try(:iri_namespace) ||
            (parents.include?(LinkedRails) ? LinkedRails::NS::ONTOLA : LinkedRails.app_ns)
        end

        delegate :route_key, to: :model_name
      end
    end
  end
end
