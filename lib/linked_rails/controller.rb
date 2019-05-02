# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/error_handling'
require_relative 'controller/rdf_error'

module LinkedRails
  module Controller
    extend ActiveSupport::Concern

    included do
      include LinkedRails::ActiveResponse::Controller
      include LinkedRails::Controller::ErrorHandling
      include LinkedRails::Helpers::OntolaActionsHelper

      class_attribute :enhancements_included
    end

    def process(action, *args)
      self.class.include_enhancements unless enhancements_included
      super
    end

    private

    def controller_class
      self.class.controller_class
    end

    module ClassMethods
      def controller_class
        @controller_class ||=
          name.sub(/Controller$/, '').classify.safe_constantize || controller_name.classify.safe_constantize
      end

      def include_enhancements
        controller_class.try(:enhancement_modules, :Controller)&.each { |mod| include mod }
        self.enhancements_included = true
      end
    end
  end
end
