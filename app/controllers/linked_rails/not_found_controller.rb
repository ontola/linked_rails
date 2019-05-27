# frozen_string_literal: true

module LinkedRails
  class NotFoundController < ApplicationController
    def show
      handle_error(ActionController::RoutingError.new('Route not found'))
    rescue ActionController::UnknownFormat
      head 404
    end

    private

    def authorize_action; end
  end
end
