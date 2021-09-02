# frozen_string_literal: true

module LinkedRails
  module Controller
    module DefaultActions
      module Update
        def has_resource_update_action(overwrite = {})
          has_resource_action(:update, **update_resource_options(overwrite))
        end

        def has_singular_update_action(overwrite = {})
          has_singular_action(:update, **update_singular_options(overwrite))
        end

        private

        def update_resource_options(overwrite = {})
          default_update_options(overwrite)
        end

        def update_singular_options(overwrite = {})
          default_update_options(overwrite)
        end

        def default_update_options(overwrite = {}) # rubocop:disable Metrics/MethodLength
          {
            action_name: :edit,
            action_path: :edit,
            execute: :update_execute,
            form: -> { resource.class.try(:form_class) },
            http_method: :put,
            image: 'fa-pencil-square-o',
            on_failure: :update_failure,
            on_success: :update_success,
            policy: :update?,
            target_path: '',
            type: Vocab.schema.UpdateAction
          }.merge(overwrite)
        end
      end
    end
  end
end
