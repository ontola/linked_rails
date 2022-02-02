# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShapeSerializer < ShapeSerializer
      attribute :closed, predicate: Vocab.sh.closed
      attribute :ignored_properties, predicate: Vocab.sh.ignoredProperties
      attribute :sparql, predicate: Vocab.sh.sparql
      has_many :property, predicate: Vocab.sh.property
    end
  end
end
