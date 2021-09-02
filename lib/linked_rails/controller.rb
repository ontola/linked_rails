# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/actionable'
require_relative 'controller/authorization'
require_relative 'controller/error_handling'

module LinkedRails
  module Controller
    extend ActiveSupport::Concern
    include ::ActiveResponse::Controller

    included do
      extend Enhanceable

      enhanceable :controller_class, :Controller

      include ActionController::MimeResponds
      include LinkedRails::ActiveResponse::Controller
      include LinkedRails::Controller::Actionable
      include LinkedRails::Controller::Authorization
      include LinkedRails::Controller::ErrorHandling
      include LinkedRails::Helpers::OntolaActionsHelper
      include LinkedRails::Helpers::DeltaHelper
      include LinkedRails::Helpers::ResourceHelper

      before_action :set_manifest_header
    end

    private

    def controller_class
      self.class.controller_class
    end

    def set_manifest_header
      response.headers['Manifest'] = LinkedRails.iri(path: '/manifest.json')
    end

    module ClassMethods
      def controller_class(klass = nil)
        if klass.present?
          @controller_class = klass
        else
          @controller_class ||= compute_controller_class || superclass.try(:controller_class)
        end
      end

      private

      def compute_controller_class
        klass =
          name.sub(/Controller$/, '').classify.safe_constantize ||
          try(:controller_name)&.classify&.safe_constantize

        klass if klass&.include?(LinkedRails::Model)
      end
    end
  end
end
