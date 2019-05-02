# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemsController < LinkedRails.controller_parent_class
      active_response :show, :index

      private

      def action_list
        parent_resource.action_list(user_context)
      end

      def index_association
        action_list.actions
      end

      def index_includes
        [:target, actions: [target: {action_body: :referred_shapes}]]
      end

      def show_includes
        [:object].concat(action_form_includes)
      end

      def requested_resource
        @requested_resource ||= action_list.action(params[:id].to_sym)
      end
    end
  end
end
