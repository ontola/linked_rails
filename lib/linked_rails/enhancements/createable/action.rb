# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Createable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(
            :create,
            collection: -> { create_on_collection? },
            description: -> { create_description },
            favorite: -> { create_action_favorite },
            form: -> { "#{result_class}Form".safe_constantize },
            http_method: :post,
            image: -> { create_image },
            label: -> { create_label },
            iri_path: -> { create_iri_path },
            policy: -> { create_policy },
            submit_label: -> { create_submit_label },
            result: -> { result_class },
            type: lambda {
              [LinkedRails::NS::ONTOLA["Create::#{result_class}"], LinkedRails::NS::SCHEMA[:CreateAction]]
            },
            url: -> { create_url }
          )
        end

        private

        def create_action_favorite
          false
        end

        def create_description; end

        def create_image
          'fa-plus'
        end

        def create_iri_path
          uri = URI(resource.iri_path)
          uri.path += '/new'
          uri.to_s
        end

        def create_label
          I18n.t("#{association}.type_new", default: "New #{result_class.name.humanize}")
        end

        def create_on_collection?
          true
        end

        def create_policy
          :create_child?
        end

        def create_submit_label; end

        def create_url
          resource.iri
        end
      end
    end
  end
end
