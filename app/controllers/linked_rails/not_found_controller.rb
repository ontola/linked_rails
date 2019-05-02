# frozen_string_literal: true

module LinkedRails
  class NotFoundController < ApplicationController
    def show
      handle_error(ActionController::RoutingError.new('Route not found'))
    end
  end
end
