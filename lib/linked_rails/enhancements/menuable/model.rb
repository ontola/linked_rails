# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Menuable
      module Model
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

          def preview_includes
            return super if menu_class.blank?

            super + menu_class.defined_menus.keys.map { |tag| "#{tag}_menu" }
          end
        end
      end
    end
  end
end
