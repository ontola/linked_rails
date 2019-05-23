# frozen_string_literal: true

module LinkedRails
  class NotFoundController < ApplicationController
    skip_before_action :authorize_action

    def show
      handle_error(ActionController::RoutingError.new('Route not found'))
    rescue ActionController::UnknownFormat
      head 404
    end
  end
end
