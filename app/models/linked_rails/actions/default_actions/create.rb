# frozen_string_literal: true

module LinkedRails
  module Actions
    module DefaultActions
      module Create
        def has_collection_create_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_collection_action(:create, create_collection_options(overwrite))
        end

        def has_singular_create_action(overwrite = {}) # rubocop:disable Naming/PredicateName
          has_singular_action(:create, create_singular_options(overwrite))
        end

        private

        def create_collection_options(overwrite = {})
          default_create_options(
            form: -> { resource.association_class.try(:form_class) },
            object: -> { resource.build_child },
            policy: :create_child?
          ).merge(overwrite)
        end

        def create_singular_options(overwrite = {})
          default_create_options(
            form: -> { resource.class.try(:form_class) },
            object: -> { resource },
            policy: :create?,
            url: -> { resource.singular_iri }
          ).merge(overwrite)
        end

        def default_create_options(overwrite = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          {
            http_method: :post,
            image: 'fa-plus',
            label: lambda do
              item = LinkedRails::Actions::Item.new(resource: result_class.new, tag: :create)
              LinkedRails.translate(:action, :label, item, false).presence ||
                I18n.t("#{association}.type_new", default: "New #{result_class.name.demodulize.humanize}")
            end,
            root_relative_iri: lambda {
              uri = resource.root_relative_iri.dup
              uri.path ||= ''
              uri.path += '/new'
              uri.query = Rack::Utils.parse_nested_query(uri.query).except('display', 'sort').to_param.presence
              uri.to_s
            },
            result: -> { result_class },
            type: lambda {
              [Vocab::ONTOLA["Create::#{result_class}"], RDF::Vocab::SCHEMA.CreateAction]
            },
            url: -> { resource.iri }
          }.merge(overwrite)
        end
      end
    end
  end
end
