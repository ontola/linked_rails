# frozen_string_literal: true

module LinkedRails
  class Form
    class Field < LinkedRails::Resource
      attr_writer :datatype,
                  :description,
                  :helper_text,
                  :label,
                  :max_length,
                  :min_count,
                  :min_length,
                  :sh_in,
                  :pattern,
                  :path
      attr_accessor :max_count,
                    :model_attribute,
                    :model_class,
                    :form,
                    :group,
                    :input_field,
                    :max_inclusive,
                    :min_inclusive,
                    :validators,
                    :key
      def datatype
        @datatype || raise("No datatype found for #{key} in #{form.name}")
      end

      def description
        description_from_attribute || LinkedRails.translate(:property, :description, self, false)
      end

      def helper_text
        helper_text_from_attribute || LinkedRails.translate(:property, :helper_text, self, false)
      end

      def max_length
        @max_length || validators[:max_length]
      end

      def min_count
        @min_count || (validators[:presence] ? 1 : nil)
      end

      def min_length
        @min_length || validators[:min_length]
      end

      def name
        label_from_attribute || LinkedRails.translate(:property, :label, self)
      end

      def pattern
        @pattern || validators[:pattern]
      end

      def path
        @path || raise("No predicate found for #{key} in #{form.name}")
      end

      def permission_required?
        true
      end

      def sh_in
        return validators[:sh_in] if @sh_in.blank?

        @sh_in.respond_to?(:call) ? @sh_in.call : @sh_in
      end

      private

      def description_from_attribute
        @description.respond_to?(:call) ? @description.call : @description
      end

      def helper_text_from_attribute
        @helper_text.respond_to?(:call) ? @helper_text.call : @helper_text
      end

      def label_from_attribute
        @label.respond_to?(:call) ? @label.call : @label
      end

      class << self
        def iri
          Vocab::FORM[name.demodulize]
        end
      end
    end
  end
end
