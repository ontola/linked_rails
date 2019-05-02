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
        @default_value || form&.target&.send(model_attribute) if model_attribute
      end

      # The placeholder of the property.
      def description
        description_from_attribute || LinkedRails.translate(:property, :description, self)
      end

      def min_count
        @min_count || validator_by_class(ActiveRecord::Validations::PresenceValidator).present? ? 1 : nil
      end

      def model_name
        @model_name ||= form&.target&.model_name&.i18n_key
      end

      def name
        LinkedRails.translate(:property, :label, self)
      end

      private

      def description_from_attribute
        return if @description.blank?

        @description.respond_to?(:call) ? @description.call(form.target) : @description
      end

      def validator_by_class(klass)
        validators&.detect { |validator| validator.is_a?(klass) }
      end

      def validator_option(klass, option_key)
        option = validator_by_class(klass)&.options.try(:[], option_key)
        option.respond_to?(:call) ? option.call(form.target) : option
      end
    end
  end
end
