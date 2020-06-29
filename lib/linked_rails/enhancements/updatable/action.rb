# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(:update, update_options)
        end

        module ClassMethods
          private

          def update_options # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
            {
              type: RDF::Vocab::SCHEMA.UpdateAction,
              policy: :update?,
              label: lambda {
                type = I18n.t("#{resource.class.name.tableize}.type", default: nil)
                type.present? ? I18n.t('edit_type', type: type) : I18n.t('update')
              },
              image: 'fa-pencil-square-o',
              include_object: false,
              url: -> { resource.iri },
              http_method: :put,
              form: -> { "#{resource.class}Form".safe_constantize },
              root_relative_iri: lambda {
                uri = resource.root_relative_iri.dup
                uri.path ||= ''
                uri.path += '/edit'
                uri.to_s
              }
            }
          end
        end
      end
    end
  end
end
