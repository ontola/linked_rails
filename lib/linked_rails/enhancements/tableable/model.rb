# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Tableable
      module Model
        extend ActiveSupport::Concern

        included do
          class_attribute :defined_columns
        end

        module ClassMethods
          def with_columns(opts)
            initialize_columns
            defined_columns.merge!(opts)
          end

          def initialize_columns
            return if defined_columns && method(:defined_columns).owner == singleton_class

            self.defined_columns = superclass.try(:defined_columns)&.dup || {}
          end
        end
      end
    end
  end
end
