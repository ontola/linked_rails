# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Menuable
      module Model
        extend ActiveSupport::Concern

        included do
          def menus(user_context = nil)
            @menus ||= self.class.menu_class
                         .new(resource: self, user_context: user_context)
                         .menus
          end

          def menu(user_context, tag)
            menus(user_context).find { |menu| menu&.tag == tag }
          end
        end

        module ClassMethods
          def menu_class
            @menu_class ||= "#{name}MenuList".safe_constantize || "#{superclass.name}MenuList".safe_constantize
          end

          def preview_includes
            super + menu_class.defined_menus.map { |tag| "#{tag}_menu" }
          end
        end
      end
    end
  end
end
