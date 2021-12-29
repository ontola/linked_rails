# frozen_string_literal: true

module LinkedRails
  module Controller
    module DefaultActions
      module Create
        def has_collection_create_action(**overwrite)
          has_collection_action(:create, **create_collection_options(**overwrite))
        end

        def has_singular_create_action(**overwrite)
          has_singular_action(:create, **create_singular_options(**overwrite))
        end

        private

        def create_collection_options(**overwrite)
          default_create_options(
            form: -> { resource.association_class.try(:form_class) },
            object: -> { resource.child_resource },
            policy: :create_child?
          ).merge(overwrite)
        end

        def create_singular_options(**overwrite)
          default_create_options(
            form: -> { resource.class.try(:form_class) },
            object: -> { resource },
            policy: :create?
          ).merge(overwrite)
        end

        def default_create_options(**overwrite) # rubocop:disable Metrics/MethodLength
          {
            action_name: :new,
            action_path: :new,
            execute: :create_execute,
            http_method: :post,
            image: 'fa-plus',
            on_failure: :create_failure,
            on_success: :create_success,
            result: -> { result_class },
            target_path: '',
            type: lambda {
              [Vocab.ontola["Create::#{result_class}"], Vocab.schema.CreateAction]
            }
          }.merge(overwrite)
        end
      end
    end
  end
end
