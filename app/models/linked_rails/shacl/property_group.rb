# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyGroup
      include ActiveModel::Model

      # Custom attributes
      attr_accessor :iri

      # SHACL attributes
      attr_writer :description,
                  :label
      attr_accessor :order

      def initialize(attrs = {})
        super(attrs)
        @iri ||= RDF::Node.new
      end

      def description
        return if @description.blank?

        @description.respond_to?(:call) ? @description.call : @description
      end

      def label
        return if @label.blank?

        @label.respond_to?(:call) ? @label.call : @label
      end

      def rdf_type
        self.class.iri
      end

      class << self
        def iri
          RDF::Vocab::SH.PropertyGroup
        end
      end
    end
  end
end
