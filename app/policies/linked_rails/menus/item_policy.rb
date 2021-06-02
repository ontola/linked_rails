# frozen_string_literal: true

module LinkedRails
  module Menus
    class ItemPolicy < LinkedRails.policy_parent_class
      def show?
        parent_policy.blank? ? true : parent_policy.show?
      end
    end
  end
end
