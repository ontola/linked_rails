# frozen_string_literal: true

module LinkedRails
  class OntologySerializer < LinkedRails.serializer_parent_class
    has_many :classes, serializer: LinkedRails::Ontology::ClassSerializer
    has_many :properties, serializer: LinkedRails::Ontology::PropertySerializer
  end
end
