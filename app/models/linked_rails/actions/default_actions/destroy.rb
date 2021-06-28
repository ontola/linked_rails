# frozen_string_literal: true

module LinkedRails
  module Actions
    module DefaultActions
      module Destroy
        def has_resource_destroy_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_resource_action(:destroy, destroy_resource_options(overwrite))
        end

        def has_singular_destroy_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_singular_action(:destroy, destroy_singular_options(overwrite))
        end

        private

        def destroy_resource_options(overwrite = {})
          default_destroy_options(overwrite)
        end

        def destroy_singular_options(overwrite = {})
          default_destroy_options(
            url: -> { resource.singular_iri }
          ).merge(overwrite)
        end

        def default_destroy_options(overwrite = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          {
            http_method: :delete,
            image: 'fa-close',
            policy: :destroy?,
            root_relative_iri: lambda {
              uri = resource.root_relative_iri.dup
              uri.path ||= ''
              uri.path += '/delete'
              uri.to_s
            },
            type: [Vocab.schema.Action, Vocab.ontola[:DestroyAction]],
            url: -> { resource.iri(destroy: true) }
          }.merge(overwrite)
        end
      end
    end
  end
end
