# frozen_string_literal: true

module LinkedRails
  module Middleware
    class ErrorHandling
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue StandardError => e
        handle_error(env, e)
      end

      private

      def controller_class(req)
        controller = req.controller_class

        return ApplicationController if controller == ActionDispatch::Request::PASS_NOT_FOUND

        controller
      rescue
        ApplicationController
      end

      def controller_instance(env)
        return env['action_controller.instance'] if env['action_controller.instance']

        req = ActionDispatch::Request.new(env)
        res = ApplicationController.make_response!(req)
        controller = controller_class(req).new
        controller.set_request!(req)
        controller.set_response!(res)

        controller
      end

      def handle_error(env, error)
        controller = controller_instance(env)

        controller.send(:handle_and_report_error, error)
        error_response = controller.response
        body = ActionDispatch::Response::RackBody.new(error_response)

        [error_response.status, error_response.headers, body]
      end
    end
  end
end
