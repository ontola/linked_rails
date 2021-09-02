# frozen_string_literal: true

module LinkedRails
  class Form
    class FieldFactory # rubocop:disable Metrics/ClassLength
      DATABASE_ERRORS = [
        'PG::ConnectionBad'.safe_constantize,
        ActiveRecord::StatementInvalid,
        ActiveRecord::ConnectionNotEstablished
      ].compact.freeze
      MAX_STR_LEN = 255
      VALIDATOR_SELECTORS = [
        [:min_length, ActiveModel::Validations::LengthValidator, :minimum],
        [:max_length, ActiveModel::Validations::LengthValidator, :maximum],
        [:pattern, ActiveModel::Validations::FormatValidator, :with],
        [:presence, ActiveModel::Validations::PresenceValidator, nil],
        [:sh_in, ActiveModel::Validations::InclusionValidator, :in]
      ].freeze
      include ActiveModel::Model

      attr_accessor :field_options, :form, :key

      delegate :form_options_iri,
               :model_class,
               :model_policy!,
               :serializer_attributes,
               :serializer_class,
               :serializer_reflections,
               to: :form

      def condition_or_field
        @condition_or_field ||= model_policy!.condition_for(
          key,
          field,
          property: field_options[:if] || [],
          sh_not: field_options[:unless] || []
        )
      end

      private

      def attr_column(name)
        column_model =
          if model_class.is_delegated_attribute?(name)
            model_class.class_for_delegated_attribute(name)
          else
            model_class
          end
        column_model.column_for_attribute(name)
      end

      def attr_to_datatype # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
        case attribute_type
        when :string, :text
          Vocab.xsd.string
        when :integer
          Vocab.xsd.integer
        when :datetime
          Vocab.xsd.dateTime
        when :date
          Vocab.xsd.date
        when :boolean
          Vocab.xsd.boolean
        when :decimal
          decimal_data_type(attribute_name)
        when :file
          Vocab.ll[:blob]
        else
          Vocab.xsd.string if model_class.try(:defined_enums)&.key?(attribute_name)
        end
      end

      def attribute_name
        serializer_attribute&.key&.to_s || key.to_s
      end

      def attribute_type
        model_class.try(:attribute_types).try(:[], attribute_name)&.type
      rescue *DATABASE_ERRORS
        :string
      end

      def attribute_validators
        @attribute_validators ||= model_class.validators.select { |v| v.attributes.include?(model_attribute) }
      end

      def datatype
        @datatype ||= field_options[:datatype] ||
          serializer_attribute.try(:datatype) ||
          (serializer_enum ? Vocab.xsd.string : attr_to_datatype)
      end

      def decimal_data_type(name) # rubocop:disable Metrics/MethodLength
        case attr_column(name).precision
        when 64
          Vocab.xsd.long
        when 32
          Vocab.xsd.int
        when 16
          Vocab.xsd.short
        when 8
          Vocab.xsd.byte
        else
          Vocab.xsd.decimal
        end
      end

      def field
        field_class.new(field_attributes)
      end

      def field_attributes # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return @field_attributes if @field_attributes

        opts = field_options.except(:if, :unless)
        opts[:form] = form
        opts[:nested_form] = field_options[:form] if field_options.key?(:form)
        opts[:model_class] = model_class
        opts[:model_attribute] = model_attribute
        opts[:key] = key
        opts[:validators] ||= validators
        opts[:path] ||= serializer_attribute&.predicate
        opts[:datatype] ||= datatype
        opts[:max_count] ||= 1
        opts[:sh_in] = form_options_iri(serializer_attribute.key.to_s) if serializer_enum && !opts[:sh_in]

        @field_attributes = opts
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def field_class
        return field_attributes[:input_field] if field_attributes.key?(:input_field)
        return max_count > 1 ? Form::Field::CheckboxGroup : Form::Field::SelectInput if sh_in
        return Form::Field::SliderInput if max_inclusive && min_inclusive

        case datatype
        when Vocab.xsd.boolean
          return Form::Field::CheckboxInput
        when Vocab.xsd.date
          return Form::Field::DateInput
        when Vocab.xsd.dateTime
          return Form::Field::DateTimeInput
        when Vocab.xsd.integer, Vocab.xsd.long, Vocab.xsd.int, Vocab.xsd.short, Vocab.xsd.byte, Vocab.xsd.decimal
          return Form::Field::NumberInput
        when Vocab.ll.blob
          return Form::Field::FileInput
        when Vocab.fhir.markdown
          return Form::Field::MarkdownInput
        when Vocab.ontola['datatype/password']
          return Form::Field::PasswordInput
        when Vocab.ontola['datatype/postalRange']
          return Form::Field::PostalRangeInput
        else
          attribute_type == :text ? Form::Field::TextAreaInput : Form::Field::TextInput
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      def max_count
        field_attributes[:max_count] || validators[:max_count]
      end

      def max_inclusive
        field_attributes[:max_inclusive] || validators[:max_inclusive] || field_attributes[:max_inclusive_prop]
      end

      def max_length
        field_attributes[:max_length] || validators[:max_length]
      end

      def min_inclusive
        field_attributes[:min_inclusive] || validators[:min_inclusive] || field_attributes[:min_inclusive_prop]
      end

      def model_attribute
        @model_attribute ||= (model_class.try(:attribute_alias, key) || key).to_sym
      end

      def normalized_key(key)
        return key.to_s[0...-3].to_sym if key.to_s.ends_with?('_id')
        return key.to_s[0...-4].pluralize.to_sym if key.to_s.ends_with?('_ids')

        key
      end

      def serializer_attribute
        return serializer_attributes[key] if serializer_attributes[key]

        @serializer_attribute ||= serializer_reflection
      end

      def serializer_enum
        @serializer_enum ||= serializer_class&.enum_options(serializer_attribute.key.to_sym) if serializer_attribute
      end

      def serializer_reflection
        k_v = serializer_reflections.find { |_k, v| (v.association || v.key) == normalized_key(key) }
        k_v[1] if k_v
      end

      def sh_in
        field_attributes[:sh_in] || validators[:sh_in]
      end

      def validator(klass, option_key)
        matched_validator = validator_by_class(klass)

        option_key ? matched_validator&.options.try(:[], option_key) : matched_validator.present?
      end

      def validator_by_class(klass)
        matched_validator = attribute_validators&.detect { |v| v.is_a?(klass) }
        return if matched_validator.blank?

        matched_validator if matched_validator.options[:if].blank? && matched_validator.options[:unless].blank?
      end

      def validators
        @validators ||= Hash[
          VALIDATOR_SELECTORS.map do |key, klass, option_key|
            [key, validator(klass, option_key)]
          end
        ]
      end
    end
  end
end
