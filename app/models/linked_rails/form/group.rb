# frozen_string_literal: true

module LinkedRails
  class Form
    class Group < LinkedRails::Resource
      attr_accessor :fields, :collapsible, :hidden, :footer
      attr_writer :description, :key, :label

      def initialize(attrs = {})
        super(attrs)
        self.fields = []
      end

      def description
        @description = @description.call if @description.respond_to?(:call)
        @description
      end

      def label
        @label = @label.call if @label.respond_to?(:call)
        @label
      end

      def rdf_type
        return Vocab::FORM[:CollapsibleGroup] if collapsible
        return Vocab::FORM[:FooterGroup] if footer
        return Vocab::FORM[:HiddenGroup] if hidden

        self.class.iri
      end

      class << self
        def iri
          Vocab::FORM[:Group]
        end
      end
    end
  end
end
