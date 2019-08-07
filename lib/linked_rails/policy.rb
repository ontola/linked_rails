# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/error_handling'

module LinkedRails
  module Policy
    extend ActiveSupport::Concern

    included do
      extend Enhanceable

      enhanceable :policy_class, :Policy

      attr_reader :user_context, :record

      def initialize(user_context, record)
        @user_context = user_context
        @record = record
      end
    end

    def create_child?(klass)
      child_policy(klass).create?
    end

    def index_children?(klass)
      child_policy(klass).show?
    end

    def show?
      false
    end

    def update?
      false
    end

    def create?
      false
    end

    def destroy?
      false
    end

    private

    def child_policy(klass)
      Pundit.policy(user_context, record.build_child(klass.constantize))
    end

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
