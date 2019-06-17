# frozen_string_literal: true

module LinkedRails
  module Controller
    module ErrorHandling
      extend ActiveSupport::Concern
      included do
        rescue_from StandardError, with: :handle_and_report_error
        rescue_from ActiveRecord::RecordNotFound, with: :handle_error
        rescue_from Pundit::NotAuthorizedError, with: :handle_error
      end

      private

      def add_error_snackbar(error)
        add_exec_action_header(response.headers, ontola_snackbar_action(error.error.message))
      end

      def add_error_snackbar?(_error)
        request.method != 'GET'
      end

      def handle_error(error)
        respond_to do |format|
          (RDF_CONTENT_TYPES + [:json]).each do |type|
            format.send(type) { error_response_serializer(error, type) }
          end
        end
      end

      def handle_and_report_error(error)
        raise if Rails.env.development? || Rails.env.test?
        raise if response_body

        handle_error(error)
      end

      def error_id(error)
        self.class.error_types[error.class.to_s].try(:[], :id) || 'SERVER_ERROR'
      end

      def error_mode(exception)
        @_error_mode = true
        Rails.logger.error exception
        @_uc = nil
      end

      def error_resource(status, error)
        LinkedRails.rdf_error_class.new(status, request.original_url, error)
      end

      def error_response_serializer(error, type, status: nil)
        status ||= error_status(error)
        error = error_resource(status, error)
        add_error_snackbar(error) if add_error_snackbar?(error)
        render type => type == :json ? error.to_json : error.graph, status: status
      end

      def error_status(error)
        self.class.error_types[error.class.to_s].try(:[], :status) || 500
      end

      module ClassMethods
        def error_types
          @error_types =
            YAML.safe_load(File.read(Rails.root.join('config', 'errors.yml'))).with_indifferent_access.freeze
        end
      end
    end
  end
end
