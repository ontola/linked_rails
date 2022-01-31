# frozen_string_literal: true

module LinkedRails
  class Ontology
    class Base
      include ActiveModel::Model
      include LinkedRails::Model
      attr_accessor :iri

      def data
        data = []
        iri.try(:each_statement) do |statement|
          next unless include_data_statement?(statement)

          statement.graph_name = ::RDF::Serializers.config.default_graph
          data << statement
        end
        data
      end

      def description
        @description ||= LinkedRails.translations(
          -> { LinkedRails.translate(self.class.translation_key, :description, iri) }
        )
      end

      def image
        @image ||= RDF::URI("http://fontawesome.io/icon/#{icon}") if icon
      end

      def label
        @label ||= LinkedRails.translations(
          -> { LinkedRails.translate(self.class.translation_key, :label, iri) }
        )
      end

      private

      def icon
        @icon ||= LinkedRails.translate(self.class.translation_key, :icon, iri)
      end

      def include_data_statement?(statement)
        return false if statement.subject.node?

        statement.predicate != Vocab.rdfs.label &&
          statement.predicate != Vocab.rdfs.range &&
          statement.predicate != Vocab.rdfs.domain
      end
    end
  end
end
