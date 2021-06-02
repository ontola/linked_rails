# frozen_string_literal: true

module LinkedRails
  module Actions
    module DefaultActions
      module Update
        def has_resource_update_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_resource_action(:update, update_resource_options(overwrite))
        end

        def has_singular_update_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_singular_action(:update, update_singular_options(overwrite))
        end

        private

        def update_resource_options(overwrite = {})
          default_update_options(overwrite)
        end

        def update_singular_options(overwrite = {})
          default_update_options(
            url: -> { resource.singular_iri }
          ).merge(overwrite)
        end

        def default_update_options(overwrite = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          {
            form: -> { resource.class.try(:form_class) },
            http_method: :put,
            image: 'fa-pencil-square-o',
            label: lambda {
              type = I18n.t("#{resource.class.name.tableize}.type", default: nil)
              type.present? ? I18n.t('edit_type', type: type) : I18n.t('update')
            },
            policy: :update?,
            root_relative_iri: lambda {
              uri = resource.root_relative_iri.dup
              uri.path ||= ''
              uri.path += '/edit'
              uri.to_s
            },
            type: RDF::Vocab::SCHEMA.UpdateAction,
            url: -> { resource.iri }
          }.merge(overwrite)
        end
      end
    end
  end
end
