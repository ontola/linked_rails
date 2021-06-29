# frozen_string_literal: true

module LinkedRails
  class Ontology
    class PropertySerializer < LinkedRails.serializer_parent_class
      attribute :description, predicate: Vocab.schema.description
      attribute :label, predicate: Vocab.rdfs.label
      attribute :image, predicate: Vocab.schema.image
      statements :data

      def self.data(object, _params)
        object.data
      end
    end
  end
end
