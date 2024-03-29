# frozen_string_literal: true

module LinkedRails
  module Model
    module Filtering
      extend ActiveSupport::Concern

      included do
        class_attribute :filter_options
      end

      module ClassMethods
        def filter_options
          class_variables.include?(:@@filter_options) ? super : {}
        end

        def filterable(**options)
          initialize_filter_options

          self.filter_options = filter_options.merge(options)

          options.map { |k, filter| define_filter_method(k, filter) }
        end

        private

        def boolean_filter(true_filter, false_filter, **options)
          {
            filter: resolve_boolean_filter(true_filter, false_filter),
            values: [true, false]
          }.merge(options)
        end

        def initialize_filter_options
          return if filter_options && method(:filter_options).owner == singleton_class

          self.filter_options = superclass.try(:filter_options)&.dup || HashWithIndifferentAccess.new
        end

        def define_filter_method(key, filter)
          method = predicate_mapping[key]&.key
          return if !method || method_defined?(method) || !filter[:attr]

          enum_map = defined_enums[method.to_s]

          if enum_map
            define_enum_filter_method(method, filter, enum_map)
          else
            define_plain_filter_method(method, filter)
          end
        end

        def define_enum_filter_method(key, filter, enum_map)
          define_method key do
            filter[:values].key(enum_map[send(filter[:attr] || key)])
          end

          define_method "#{key}=" do |value|
            send("#{filter[:attr]}=", enum_map.key(filter[:values][value&.to_sym]))
          end
        end

        def define_plain_filter_method(key, filter)
          define_method key do
            filter[:values][send(filter[:attr])]
          end

          define_method "#{key}=" do |value|
            send("#{filter[:attr]}=", filter[:values].key(value))
          end
        end

        def resolve_boolean_filter(true_filter, false_filter)
          lambda { |scope, values|
            if values.include?(true) && values.include?(false)
              scope
            else
              values.reduce(scope) do |_sub_scope, val|
                val ? true_filter.call(scope) : false_filter.call(scope)
              end
            end
          }
        end
      end
    end
  end
end
