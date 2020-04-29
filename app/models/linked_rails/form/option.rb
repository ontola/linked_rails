# frozen_string_literal: true

module LinkedRails
  class Form
    class Option
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :attr, :iri, :key, :klass, :type
      attr_writer :label

      def label
        label_from_variable ||
          I18n.t(
            "activerecord.attributes.#{class_name}.#{attr.pluralize}",
            default: [:"#{class_name.tableize}.#{attr}.#{key}", key.to_s.humanize]
          )
      end

      def rdf_type
        type
      end

      def to_param
        key
      end

      private

      def class_name
        klass.to_s.underscore
      end

      def label_from_variable
        @label.respond_to?(:call) ? @label.call : @label
      end
    end
  end
end
