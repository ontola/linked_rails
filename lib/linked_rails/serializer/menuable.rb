# frozen_string_literal: true

module LinkedRails
  module Serializer
    module Menuable
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
                    predicate: Vocab.ontola["#{menu.to_s.camelize(:lower)}Menu"],
                    if: method(:named_object?),
                    polymorphic: true do |object, opts|
              object.menu(menu, opts[:scope])
            end
          end
        end
      end
    end
  end
end
