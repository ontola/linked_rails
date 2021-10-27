# frozen_string_literal: true

module LinkedRails
  class Collection
    module Configuration
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def define_default_option_method(option)
          attr_accessor "default_#{option}"
        end

        def define_getter_option_method(option)
          attr_writer option

          define_method(option) do
            resolve_collection_option(option)
          end
        end
      end

      included do
        attr_accessor :iri_template

        LinkedRails::Model::Collections::COLLECTION_CUSTOMIZABLE_OPTIONS.each_key do |option|
          define_default_option_method(option)
        end
        LinkedRails::Model::Collections::COLLECTION_OPTIONS.each_key do |option|
          define_getter_option_method(option)
        end

        def display
          resolve_collection_option(:display)&.to_sym
        end

        def type
          resolve_collection_option(:type)&.to_sym
        end
      end

      private

      def resolve_collection_option(option)
        var_name = :"@#{option}"
        default_method_name = "default_#{option}"

        var = instance_variable_defined?(var_name) ? instance_variable_get(var_name) : try(default_method_name)

        var.respond_to?(:call) ? instance_exec(&var) : var
      end
    end
  end
end
