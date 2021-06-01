# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Singularable
      module Controller
        extend ActiveSupport::Concern

        private

        def create_meta
          data = super
          data << same_as_statement
          data
        end

        def destroy_meta
          data = super
          data << remove_same_as_delta
          data
        end

        def same_as_statement
          return [] unless current_resource.respond_to?(:singular_iri)

          [
            current_resource.singular_iri,
            NS::OWL.sameAs,
            current_resource.iri
          ]
        end

        def singular_route?
          params[:singular_route]
        end

        def remove_same_as_delta
          invalidate_resource_delta(current_resource.singular_iri)
        end
      end
    end
  end
end
