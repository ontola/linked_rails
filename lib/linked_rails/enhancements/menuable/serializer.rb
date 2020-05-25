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
            super
            target.include_menus
          end

          def include_menus
            serializable_class.try(:menu_class)&.defined_menus&.keys&.each do |menu|
              has_one "#{menu}_menu",
                      predicate: Vocab::ONTOLA["#{menu.to_s.camelize(:lower)}Menu"],
                      polymorphic: true do |object, opts|
                object.menu(menu, opts[:scope])
              end
            end
          end
        end
      end
    end
  end
end
