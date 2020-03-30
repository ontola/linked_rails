# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Creatable
      module Action
        extend ActiveSupport::Concern

        included do
          has_action(:create, create_options)
        end

        module ClassMethods
          private

          def create_options # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
            {
              collection: true,
              favorite: false,
              form: -> { result_class.try(:form_class) },
              http_method: :post,
              image: 'fa-plus',
              include_resource: false,
              label: -> { I18n.t("#{association}.type_new", default: "New #{result_class.name.humanize}") },
              root_relative_iri: lambda {
                uri = resource.root_relative_iri.dup
                uri.path ||= ''
                uri.path += '/new'
                uri.query = Rack::Utils.parse_nested_query(uri.query).except('display', 'sort').to_param.presence
                uri.to_s
              },
              policy: :create_child?,
              result: -> { result_class },
              type: lambda {
                [Vocab::ONTOLA["Create::#{result_class}"], RDF::Vocab::SCHEMA.CreateAction]
              },
              url: -> { resource.iri }
            }
          end
        end
      end
    end
  end
end
