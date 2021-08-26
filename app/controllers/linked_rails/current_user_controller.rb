# frozen_string_literal: true

module LinkedRails
  class CurrentUserController < LinkedRails.controller_parent_class
    active_response :show

    private

    def current_resource
      @current_resource ||= LinkedRails.current_user_class.new(user: current_user)
    end
  end
end
