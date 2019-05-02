# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/error_handling'
require_relative 'controller/rdf_error'

module LinkedRails
  module Policy
    extend ActiveSupport::Concern

    included do
      class_attribute :enhancements_included
    end

    def initialize(*args)
      self.class.include_enhancements unless enhancements_included
      super
    end

    private

    def policy_class
      self.class.policy_class
    end

    module ClassMethods
      def policy_class
        @policy_class ||= name.sub(/Policy/, '').classify.safe_constantize
      end

      def include_enhancements
        policy_class.try(:enhancement_modules, :Policy)&.each { |mod| include mod }
        self.enhancements_included = true
      end
    end
  end
end
