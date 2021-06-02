# frozen_string_literal: true

module LinkedRails
  module Model
    module Indexable
      extend ActiveSupport::Concern

      module ClassMethods
        def collection_from_parent(params)
          parent = parent_from_params(params, params[:user_context])
          return if parent.blank?

          collection_name = collection_from_parent_name(parent, params)

          parent.send(collection_name, params) if collection_name
        end

        def root_collection(params = {})
          return unless root_collection?

          root_collection_class.collection_or_view(root_collection_opts, params)
        end

        def root_collection_class
          LinkedRails.collection_class
        end

        private

        def collection_from_parent_name(parent, _params)
          collection_name = "#{name.underscore}_collection"

          collection_name if parent.respond_to?(collection_name, true)
        end

        def grid_max_columns; end

        def root_collection_opts
          {
            association_class: self,
            grid_max_columns: grid_max_columns
          }
        end

        def root_collection?
          true
        end
      end
    end
  end
end
