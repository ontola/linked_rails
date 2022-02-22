# frozen_string_literal: true

module LinkedRails
  module Model
    module Menuable
      extend ActiveSupport::Concern

      def menus(user_context = nil)
        menu_list(user_context).menus
      end

      def menu(tag, user_context = nil)
        menu_list(user_context).menu(tag)
      end

      def menu_list(user_context = nil)
        @menu_list = {}
        @menu_list[user_context] ||= self.class.menu_class.new(resource: self, user_context: user_context)
      end

      module ClassMethods
        def menu_class
          @menu_class ||= "#{name}MenuList".safe_constantize || "#{superclass.name}MenuList".safe_constantize
        end
      end
    end
  end
end
