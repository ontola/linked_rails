# frozen_string_literal: true

module LinkedRails
  module Controller
    module Authorization
      extend ActiveSupport::Concern

      def authorize_action
        query = action_name == 'index' ? :show? : "#{params[:action].chomp('!')}?"

        authorize(current_resource!, query)
      end
    end
  end
end
