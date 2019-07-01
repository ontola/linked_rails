# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(
            :destroy,
            type: [NS::SCHEMA[:Action], NS::ONTOLA[:DestroyAction]],
            policy: :destroy?,
            image: 'fa-close',
            url: -> { resource.iri(destroy: true) },
            http_method: :delete,
            root_relative_iri: -> { destroy_iri_path },
            favorite: -> { destroy_action_favorite }
          )
        end

        private

        def destroy_action_favorite
          false
        end

        def destroy_iri_path
          uri = resource.root_relative_iri.dup
          uri.path ||= ''
          uri.path += '/delete'
          uri.to_s
        end
      end
    end
  end
end
