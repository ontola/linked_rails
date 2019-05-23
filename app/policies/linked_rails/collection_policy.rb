# frozen_string_literal: true

module LinkedRails
  class CollectionPolicy < LinkedRails.policy_parent_class
    def create_child?
      if parent_policy
        parent_policy.create_child?(record.association_class.name)
      else
        Pundit.policy(user_context, record.association_class.new).create?
      end
    end

    def show?
      if parent_policy
        parent_policy&.index_children?(record.association_class.name)
      else
        Pundit.policy(user_context, record.association_class.new).show?
      end
    end

    private

    def parent_policy
      return if record.parent.blank?

      @parent_policy ||= Pundit.policy(user_context, record.parent)
    end
  end
end
