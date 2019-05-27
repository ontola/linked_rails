# frozen_string_literal: true

module LinkedRails
  module Controller
    module Authorization
      extend ActiveSupport::Concern

      def authorize_action # rubocop:disable Metrics/AbcSize
        if action_name == 'index'
          raise('No collection present to authorize') if index_collection.blank?

          authorize index_collection, :show?
        else
          raise('No resource present to authorize') if current_resource.blank?

          authorize current_resource, "#{params[:action].chomp('!')}?"
        end
      end
    end
  end
end
