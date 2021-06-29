# frozen_string_literal: true

module LinkedRails
  class Ontology
    class ClassSerializer < LinkedRails.serializer_parent_class
      attribute :description, predicate: Vocab.schema.description
      attribute :input_select_property, predicate: Vocab.ontola['forms/inputs/select/displayProp']
      attribute :label, predicate: Vocab.rdfs.label
      attribute :plural_label, predicate: Vocab.ontola[:pluralLabel]
      attribute :image, predicate: Vocab.schema.image
      attribute :parent_class, predicate: Vocab.rdfs.subClassOf
      statements :data

      def self.data(object, _params)
        object.data
      end
    end
  end
end
