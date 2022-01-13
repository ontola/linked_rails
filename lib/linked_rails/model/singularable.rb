# frozen_string_literal: true

module LinkedRails
  module Model
    module Singularable
      extend ActiveSupport::Concern

      included do
        attr_accessor :singular_resource
      end

      def root_relative_singular_iri(**opts)
        RDF::URI(singular_iri_template.expand(singular_iri_opts.merge(opts)))
      end

      def root_relative_iri(**opts)
        return super unless anonymous_iri?

        root_relative_singular_iri(**opts)
      end

      def singular_iri(**opts)
        return iri_with_root(root_relative_singular_iri(**opts)) if opts.present?

        @singular_iri ||= iri_with_root(root_relative_singular_iri)
      end

      def singular_iri_opts
        {}
      end

      def singular_iri_template
        self.class.singular_iri_template
      end

      def singular_resource?
        singular_resource || false
      end

      class_methods do
        delegate :singular_route_key, to: :model_name

        def requested_singular_resource(_params, _user_context)
          raise(NotImplementedError)
        end

        def singular_iri_template
          @singular_iri_template ||= LinkedRails::URITemplate.new("{/parent_iri*}/#{singular_route_key}{#fragment}")
        end
      end
    end
  end
end
