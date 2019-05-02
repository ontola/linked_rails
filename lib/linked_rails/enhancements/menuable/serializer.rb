# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Menuable
      module Serializer
        extend ActiveSupport::Concern

        included do
          include_menus
        end

        module ClassMethods
          def inherited(target)
            target.include_menus
            super
          end

          def include_menus
            serializable_class.try(:menu_class)&.defined_menus&.keys&.each do |menu|
              method_name = "#{menu}_menu"
              define_method method_name do
                object.menu(menu, scope)
              end

              has_one method_name, predicate: NS::ONTOLA["#{menu.to_s.camelize(:lower)}Menu"]
            end
          end
        end
      end
    end
  end
end
