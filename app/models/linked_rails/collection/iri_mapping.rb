# frozen_string_literal: true

module LinkedRails
  class Collection
    module IriMapping
      extend ActiveSupport::Concern

      class_methods do
        def collection_or_view(options, params)
          params_parser = params_parser_class.new(params)
          collection = new(**merge_collection_opts(options, params_parser))
          view_params = collection_view_params(params_parser)

          view_params.present? ? collection&.view_with_opts(view_params) : collection
        end

        private

        def collection_params(parser)
          parser.collection_params
        end

        def collection_view_params(params_parser)
          params_parser.collection_view_params
        end

        def merge_collection_opts(options, params_parser)
          transformed_options = options.transform_keys do |key|
            LinkedRails::Model::Collections::COLLECTION_CUSTOMIZABLE_OPTIONS.key?(key.to_sym) ? "default_#{key}" : key
          end

          transformed_options.merge(collection_params(params_parser))
        end

        def params_parser_class
          LinkedRails::CollectionParamsParser
        end
      end
    end
  end
end
