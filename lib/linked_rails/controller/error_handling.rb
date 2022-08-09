# frozen_string_literal: true

module LinkedRails
  module Controller
    module ErrorHandling
      extend ActiveSupport::Concern
      include ActiveSupport::Rescuable

      included do
        rescue_from LinkedRails::Errors::Forbidden, with: :handle_error
      end

      private

      def add_error_snackbar(error)
        add_exec_action_header(response.headers, ontola_snackbar_action(error.error.message))
      end

      def add_error_snackbar?(_error)
        !%w[GET HEAD].include?(request.method)
      end

      def handle_and_report_error(error)
        report_error(error) if error_status(error) == 500
        handle_error(error)
      end

      def handle_error(error)
        raise(error) if response_body

        respond_to do |format|
          (LinkedRails::Renderers.rdf_content_types + [:json]).each do |type|
            format.send(type) { error_response_serializer(error, type) }
          end
        end
      end

      def report_error(error)
        raise(error) if Rails.env.development? || Rails.env.test?

        Rails.logger.error(error)
      end

      def error_mode(exception)
        @_error_mode = true
        Rails.logger.error exception
        @_uc = nil
      end

      def error_resource(status, error, url = request.original_url)
        LinkedRails.rdf_error_class.new(status, url, error)
      end

      def error_response_serializer(error, type, status: nil)
        status ||= error_status(error)
        error = error_resource(status, error)
        add_error_snackbar(error) if add_error_snackbar?(error)
        render type => error, status: status
      end

      def error_status(error)
        self.class.error_status_codes[error.class.to_s] || 500
      end

      module ClassMethods
        def error_status_codes # rubocop:disable Metrics/MethodLength
          @error_status_codes ||= {
            'ActionController::ParameterMissing' => 422,
            'ActionController::RoutingError' => 404,
            'ActionController::UnpermittedParameters' => 422,
            'ActiveRecord::RecordNotFound' => 404,
            'ActiveRecord::RecordNotUnique' => 304,
            'Doorkeeper::Errors::InvalidGrantReuse' => 422,
            'LinkedRails::Auth::Errors::Expired' => 410,
            'LinkedRails::Auth::Errors::Unauthorized' => 401,
            'LinkedRails::Errors::Forbidden' => 403,
            'Pundit::NotAuthorizedError' => 403
          }
        end
      end
    end
  end
end
