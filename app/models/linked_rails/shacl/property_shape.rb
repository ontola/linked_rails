# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShape < Shape
      class << self
        def iri
          NS::SH[:PropertyShape]
        end

        def validations(*validations)
          validations.each do |key, klass, option_key|
            attr_writer key

            define_method key do
              instance_variable_get(:"@#{key}") || validator_option(klass, option_key)
            end
          end
        end
      end

      # Custom attributes
      attr_accessor :model_attribute, :form

      # SHACL attributes
      attr_accessor :sh_class,
                    :datatype,
                    :group,
                    :input_field,
                    :model_class,
                    :node,
                    :node_kind,
                    :node_shape,
                    :max_count,
                    :order,
                    :path,
                    :validators
      attr_writer :default_value, :description, :min_count, :model_name

      validations [:min_length, ActiveRecord::Validations::LengthValidator, :minimum],
                  [:max_length, ActiveRecord::Validations::LengthValidator, :maximum],
                  [:pattern, ActiveModel::Validations::FormatValidator, :with],
                  [:sh_in, ActiveModel::Validations::InclusionValidator, :in]

      def default_value
        @default_value ||= default_value_from_target
      end

      # The placeholder of the property.
      def description
        description_from_attribute || LinkedRails.translate(:property, :description, self)
      end

      def min_count
        @min_count || (validator_by_class(ActiveRecord::Validations::PresenceValidator).present? ? 1 : nil)
      end

      def model_name
        @model_name ||= form&.target&.model_name&.i18n_key
      end

      def name
        LinkedRails.translate(:property, :label, self)
      end

      def sh_in
        @sh_in = form.instance_exec(&@sh_in) if @sh_in.respond_to?(:call)
        @sh_in
      end

      private

      def apply_if_option(option)
        return form.target.send(option) if option.is_a?(Symbol)
        return form.target.instance_exec(option) if option.respond_to?(:call)
      end

      def default_value_from_sh_in(value)
        sh_in.detect { |v| v.is_a?(LinkedRails::Form::Option) && v.key == value.to_sym }&.iri
      end

      def default_value_from_target
        return if model_attribute.blank? || !form&.target&.respond_to?(model_attribute) || sh_class.present?

        sanitized_default_value(form.target.send(model_attribute))
      end

      def description_from_attribute
        return if @description.blank?

        @description.respond_to?(:call) ? form.instance_exec(&@description) : @description
      end

      def sanitized_default_value(value)
        return default_value_from_sh_in(value) if value.is_a?(String) && sh_in.is_a?(Array)

        value if value.is_a?(String) || value.is_a?(RDF::URI) || RDF::Literal.new(value).class < RDF::Literal
      end

      def validator_by_class(klass)
        validator = validators&.detect { |validator| validator.is_a?(klass) }
        return unless validator

        if_value = apply_if_option(validator.options[:if])
        return if if_value == false

        unless_value = apply_if_option(validator.options[:unless])
        return if unless_value == true

        validator
      end

      def validator_option(klass, option_key)
        option = validator_by_class(klass)&.options.try(:[], option_key)
        option.respond_to?(:call) ? option.call(form.target) : option
      end
    end
  end
end
