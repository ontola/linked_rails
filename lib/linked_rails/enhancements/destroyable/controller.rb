# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Serializer
        extend ActiveSupport::Concern

        included do
          include_menus
        end

        def include_menus?
          true
        end

        module ClassMethods
          def inherited(target)
            target.include_menus
            super
          end

          def include_menus
            serializable_class.menu_class.defined_menus.each do |menu|
              method_name = "#{menu}_menu"
              define_method method_name do
                object.menu(scope, menu)
              end

              has_one method_name, predicate: NS::ONTOLA["#{menu.to_s.camelize(:lower)}Menu"], unless: :include_menus?
            end
          end
        end
      end
    end
  end
end
