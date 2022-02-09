# frozen_string_literal: true

module LinkedRails
  class Form
    class Group < LinkedRails::Resource
      attr_accessor :fields, :collapsible, :hidden, :footer
      attr_writer :description, :key, :label

      def initialize(**attrs)
        super(**attrs)
        self.fields = []
      end

      def description
        @description.respond_to?(:call) ? @description.call : @description
      end

      def label
        @label.respond_to?(:call) ? @label.call : @label
      end

      def rdf_type
        return Vocab.form[:CollapsibleGroup] if collapsible
        return Vocab.form[:FooterGroup] if footer
        return Vocab.form[:HiddenGroup] if hidden

        self.class.iri
      end

      class << self
        def iri
          Vocab.form[:Group]
        end
      end
    end
  end
end
