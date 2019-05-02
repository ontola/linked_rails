# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/error_handling'

module LinkedRails
  module Policy
    extend ActiveSupport::Concern

    included do
      extend Enhanceable

      enhanceable :policy_class, :Policy
    end

    private

    def policy_class
      self.class.policy_class
    end

    module ClassMethods
      def policy_class
        @policy_class ||= name.sub(/Policy/, '').classify.safe_constantize
      end
    end
  end
end
