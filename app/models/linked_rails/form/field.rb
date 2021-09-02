# frozen_string_literal: true

module LinkedRails
  class Form
    class Field < LinkedRails::Resource
      attr_writer :description,
                  :helper_text,
                  :label,
                  :max_length,
                  :min_count,
                  :min_length,
                  :sh_in,
                  :pattern,
                  :path
      attr_accessor :datatype,
                    :default_value,
                    :max_count,
                    :max_count_prop,
                    :max_inclusive,
                    :max_inclusive_prop,
                    :max_length_prop,
                    :min_count_prop,
                    :min_inclusive,
                    :min_inclusive_prop,
                    :min_length_prop,
                    :model_attribute,
                    :model_class,
                    :form,
                    :group,
                    :input_field,
                    :validators,
                    :sh_in_prop,
                    :key

      def description
        description_from_attribute || description_fallback
      end

      def helper_text
        helper_text_from_attribute || helper_text_fallback
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
        label_from_attribute || label_fallback
      end

      def pattern
        p = @pattern || validators[:pattern]
        p.respond_to?(:call) ? p.call(nil) : p
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

      def description_fallback
        LinkedRails.translate(:field, :description, self, false)
      end

      def helper_text_from_attribute
        @helper_text.respond_to?(:call) ? @helper_text.call : @helper_text
      end

      def helper_text_fallback
        LinkedRails.translate(:field, :helper_text, self, false)
      end

      def label_from_attribute
        @label.respond_to?(:call) ? @label.call : @label
      end

      def label_fallback
        LinkedRails.translate(:field, :label, self, false).presence || label_from_property
      end

      def label_from_property
        LinkedRails.translate(:property, :label, path) if path
      end

      class << self
        def iri
          Vocab.form[name.demodulize]
        end
      end
    end
  end
end
