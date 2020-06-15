# frozen_string_literal: true

module LinkedRails
  class EnumValuePolicy < LinkedRails.policy_parent_class
    class Scope < Scope
      def initialize(context, scope)
        @context = context
        @scope = scope
      end

      def resolve
        return scope if scope.blank? || !parent_policy.respond_to?(filter_method)

        scope.select { |option| valid_options.include?(option.key) }
      end

      private

      def filter_method
        "valid_#{scope.first.attr}_options"
      end

      def parent_policy
        @parent_policy ||= Pundit::PolicyFinder.new(scope.first.klass).policy
      end

      def valid_options
        @valid_options ||= parent_policy.send(filter_method)
      end
    end
  end
end
