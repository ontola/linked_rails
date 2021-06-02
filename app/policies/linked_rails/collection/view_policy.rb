# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewPolicy < LinkedRails.policy_parent_class
      delegate :show?, to: :parent_policy

      def parent_policy
        @parent_policy ||= Pundit.policy(user_context, record.collection)
      end
    end
  end
end
