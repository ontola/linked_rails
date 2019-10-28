# frozen_string_literal: true

module LinkedRails
  module Controller
    module Authorization
      extend ActiveSupport::Concern

      def authorize_action
        if action_name == 'index'
          raise ActiveRecord::RecordNotFound, 'No collection present to authorize' if index_collection.blank?

          authorize index_collection, :show?
        else
          raise ActiveRecord::RecordNotFound, 'No resource present to authorize' if current_resource.blank?

          authorize current_resource, "#{params[:action].chomp('!')}?"
        end
      end
    end
  end
end
