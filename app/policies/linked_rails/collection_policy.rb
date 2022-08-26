# frozen_string_literal: true

module LinkedRails
  class CollectionPolicy < LinkedRails.policy_parent_class
    delegate :permitted_attributes, :permitted_attributes_from_filters, to: :child_policy

    def create_child?
      policy = Pundit.policy!(user_context, child_resource)
      verdict = policy.create?
      @message = policy.message
      @action_status = policy.action_status
      verdict
    end

    def show?
      if parent_policy
        parent_policy.index_children?(
          record.association_class,
          user_context: user_context
        )
      else
        Pundit.policy(user_context, child_resource).show?
      end
    end

    private

    def child_policy
      @child_policy ||= Pundit.policy(user_context, child_resource) if child_resource
    end

    def child_resource
      record.child_resource
    end

    def parent_policy
      return super unless record.parent.is_a?(LinkedRails.collection_class)

      @parent_policy ||= Pundit.policy(user_context, record.parent.parent)
    end
  end
end
