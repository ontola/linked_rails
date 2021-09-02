# frozen_string_literal: true

module LinkedRails
  module Controller
    module Authorization
      extend ActiveSupport::Concern

      def authorize_action
        return authorize_action_item if current_resource!.is_a?(LinkedRails.actions_item_class)

        query = action_name == 'index' ? :show? : "#{params[:action].chomp('!')}?"

        authorize(current_resource!, query)
      end

      def authorize_action_item
        authorize(current_resource!.resource, :show?) if current_resource!.resource
      end
    end
  end
end
