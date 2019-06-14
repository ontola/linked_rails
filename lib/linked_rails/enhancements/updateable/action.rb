# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updateable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(
            :update,
            description: -> { update_description },
            type: NS::SCHEMA[:UpdateAction],
            policy: :update?,
            label: -> { update_label },
            image: 'fa-pencil-square-o',
            include_resource: -> { update_include_resource? },
            url: -> { update_url },
            http_method: :put,
            form: -> { "#{resource.class}Form".safe_constantize },
            iri_path: -> { update_iri_path }
          )
        end

        def update_description; end

        def update_include_resource?
          false
        end

        def update_iri_path
          uri = URI(resource.iri_path)
          uri.path += '/edit'
          uri.to_s
        end

        def update_label
          type = I18n.t("#{resource.class.name.tableize}.type", default: nil)
          type.present? ? I18n.t('edit_type', type: type) : I18n.t('update')
        end

        def update_template_opts
          {}
        end

        def update_url
          resource.iri
        end
      end
    end
  end
end
