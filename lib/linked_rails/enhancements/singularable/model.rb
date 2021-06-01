# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Singularable
      module Model
        extend ActiveSupport::Concern

        included do
          attr_accessor :singular_resource

          alias_method :singular_resource?, :singular_resource
        end

        def root_relative_singular_iri(opts = {})
          RDF::URI(self.class.singular_iri_template.expand(singular_iri_opts.merge(opts)))
        end

        def root_relative_iri(opts = {})
          return super unless anonymous_iri?

          root_relative_singular_iri(opts)
        end

        def singular_iri(opts = {})
          return iri_with_root(root_relative_singular_iri(opts)) if opts.present?

          @singular_iri ||= iri_with_root(root_relative_singular_iri)
        end

        class_methods do
          def requested_singular_resource(_params, _user_context)
            raise(NotImplementedError)
          end

          def singular_iri_template
            @singular_iri_template ||= URITemplate.new("{/parent_iri*}/#{singular_route_key}{#fragment}")
          end

          def singular_route_key
            raise(NotImplementedError)
          end
        end
      end
    end
  end
end
