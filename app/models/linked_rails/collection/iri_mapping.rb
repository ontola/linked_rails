# frozen_string_literal: true

module LinkedRails
  class Collection
    module IriMapping
      extend ActiveSupport::Concern

      class_methods do
        def collection_or_view(options, params)
          parser = params_parser_class.new(params)
          collection = new(options.merge(collection_params(parser)))
          view_params = collection_view_params(parser)

          view_params.present? ? collection&.view_with_opts(view_params) : collection
        end

        private

        def collection_params(parser)
          parser.collection_params
        end

        def collection_view_params(parser)
          parser.collection_view_params
        end

        def params_parser_class
          LinkedRails::CollectionParamsParser
        end
      end
    end
  end
end
