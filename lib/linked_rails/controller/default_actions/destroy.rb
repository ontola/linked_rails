# frozen_string_literal: true

module LinkedRails
  module Controller
    module DefaultActions
      module Destroy
        def has_resource_destroy_action(**overwrite)
          has_resource_action(:destroy, **destroy_resource_options(**overwrite))
        end

        def has_singular_destroy_action(**overwrite)
          has_singular_action(:destroy, **destroy_singular_options(**overwrite))
        end

        private

        def destroy_resource_options(**overwrite)
          default_destroy_options(**overwrite)
        end

        def destroy_singular_options(**overwrite)
          default_destroy_options(**overwrite)
        end

        def default_destroy_options(**overwrite) # rubocop:disable Metrics/MethodLength
          {
            action_name: :delete,
            action_path: :delete,
            execute: :destroy_execute,
            http_method: :delete,
            image: 'fa-close',
            on_failure: :destroy_failure,
            on_success: :destroy_success,
            policy: :destroy?,
            target_path: '',
            type: [Vocab.schema.Action, Vocab.ontola[:DestroyAction]]
          }.merge(overwrite)
        end
      end
    end
  end
end
