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
        @default_value ||= default_value_from_target
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

      def default_value_from_target # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        return if model_attribute.blank? || form&.target&.blank? || sh_class.present?

        value = form.target.send(model_attribute)
        value if value.is_a?(String) || value.is_a?(RDF::URI) || RDF::Literal.new(value).class < RDF::Literal
      end

      def description_from_attribute
        return if @description.blank?

        @description.respond_to?(:call) ? form.instance_exec(&@description) : @description
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
