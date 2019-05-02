# frozen_string_literal: true

module LinkedRails
  module Model
    module Filtering
      extend ActiveSupport::Concern

      def applicable_filters
        Hash[self.class.filter_options.keys.map { |k| [k, send(k)] }]
      end

      module ClassMethods
        def filter_options
          class_variables.include?(:@@filter_options) ? super : {}
        end

        def filterable(options = {})
          class_attribute :filter_options
          self.filter_options = HashWithIndifferentAccess.new(options)

          options.map { |k, filter| define_filter_method(k, filter) }
        end

        private

        def define_filter_method(key, filter)
          return if method_defined?(key) || filter[:attr].blank?

          enum_map = defined_enums[filter[:attr].to_s]

          if enum_map
            define_enum_filter_method(key, filter, enum_map)
          else
            define_plain_filter_method(key, filter)
          end
        end

        def define_enum_filter_method(key, filter, enum_map)
          define_method key do
            filter[:values].key(enum_map[send(filter[:attr])])
          end

          define_method "#{key}=" do |value|
            send("#{filter[:attr]}=", enum_map.key(filter[:values][value&.to_sym]))
          end
        end

        def define_plain_filter_method(key, filter)
          define_method key do
            filter.values[send(filter[:attr])]
          end

          define_method "#{key}=" do |value|
            send("#{filter[:attr]}=", filter[:values].key(value))
          end
        end
      end
    end
  end
end
