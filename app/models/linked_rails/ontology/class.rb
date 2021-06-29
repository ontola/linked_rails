# frozen_string_literal: true

require_relative './base'

module LinkedRails
  class Ontology
    class Class < Base
      attr_accessor :klass

      def input_select_property
        klass.try(:input_select_property)
      end

      def parent_class
        if klass.superclass == ApplicationRecord
          Vocab.schema.Thing
        else
          klass.superclass.iri
        end
      end

      def plural_label
        @plural_label ||= LinkedRails.translations(
          -> { LinkedRails.translate(self.class.translation_key, :plural_label, iri) }
        )
      end

      def properties
        @properties ||= klass.predicate_mapping.keys.map { |key| LinkedRails.ontology_property_class.new(iri: key) }
      end

      class << self
        def iri
          Vocab.rdfs.Class
        end

        def translation_key
          :class
        end
      end
    end
  end
end
