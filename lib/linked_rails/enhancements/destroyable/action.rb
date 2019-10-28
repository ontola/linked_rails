# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(:destroy, destroy_options)
        end

        module ClassMethods
          private

          def destroy_options # rubocop:disable Metrics/MethodLength
            {
              type: [RDF::Vocab::SCHEMA.Action, Vocab::ONTOLA[:DestroyAction]],
              policy: :destroy?,
              image: 'fa-close',
              url: -> { resource.iri(destroy: true) },
              http_method: :delete,
              root_relative_iri: lambda {
                uri = resource.root_relative_iri.dup
                uri.path ||= ''
                uri.path += '/delete'
                uri.to_s
              },
              favorite: false
            }
          end
        end
      end
    end
  end
end
