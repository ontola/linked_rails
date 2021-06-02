# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemsController < LinkedRails.controller_parent_class
      active_response :show

      private

      def include_collection_items?
        false
      end

      def show_includes
        [:target, included_object: current_resource.form_resource_includes]
      end
    end
  end
end
