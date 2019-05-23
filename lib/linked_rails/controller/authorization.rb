# frozen_string_literal: true

module LinkedRails
  module Controller
    module Authorization
      extend ActiveSupport::Concern
      included do
        before_action :authorize_action
      end

      def authorize_action
        if action_name == 'index'
          authorize index_collection, :show?
        else
          authorize current_resource, "#{params[:action].chomp('!')}?"
        end
      end
    end
  end
end
