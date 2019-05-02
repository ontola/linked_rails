# frozen_string_literal: true

module LinkedRails
  class CollectionPolicy < LinkedRails.policy_parent_class
    def create_child?
      parent_policy&.create_child?(record.association_class.name.tableize.to_sym)
    end

    private

    def parent_policy
      return if record.parent.blank?

      @parent_policy ||= Pundit.policy(user_context, record.parent)
    end
  end
end
