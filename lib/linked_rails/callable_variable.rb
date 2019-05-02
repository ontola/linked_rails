# frozen_string_literal: true

module LinkedRails
  module CallableVariable
    extend ActiveSupport::Concern

    module ClassMethods
      def callable_variable(method, opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        variable ||= opts[:variable] || method
        default ||= opts[:default]

        define_method method do
          value = instance_variable_get("@#{variable}")
          if value.respond_to?(:call)
            instance = opts[:instance] ? send(opts[:instance]) : self
            value = instance_variable_set("@#{variable}", instance.instance_exec(&value))
          end
          return value if !value.nil? || default.blank?

          instance_exec(&default)
        end
      end
    end
  end
end
