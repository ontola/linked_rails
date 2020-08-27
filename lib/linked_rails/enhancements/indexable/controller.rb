# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Indexable
      module Controller
        private

        def collection_from_parent
          return if collection_from_parent_name.blank?

          parent_resource!.send(
            collection_from_parent_name,
            collection_options
          )
        end

        def collection_from_parent_name
          return unless parent_resource.respond_to?("#{controller_name.singularize}_collection", true)

          "#{controller_name.singularize}_collection"
        end

        def index_collection
          @index_collection ||= collection_from_parent || root_collection
        end

        def root_collection
          controller_class.try(:root_collection, collection_options)
        end
      end
    end
  end
end
