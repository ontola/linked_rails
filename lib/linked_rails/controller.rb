# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/authorization'
require_relative 'controller/error_handling'

module LinkedRails
  module Controller
    extend ActiveSupport::Concern

    included do
      extend Enhanceable

      enhanceable :controller_class, :Controller

      include LinkedRails::ActiveResponse::Controller
      include LinkedRails::Controller::Authorization
      include LinkedRails::Controller::ErrorHandling
      include LinkedRails::Helpers::OntolaActionsHelper
      include LinkedRails::Helpers::DeltaHelper
      include LinkedRails::Helpers::ResourceHelper
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
    end
  end
end
