# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShapeSerializer < ShapeSerializer
      attribute :closed, predicate: RDF::Vocab::SH.closed
      attribute :ignored_properties, predicate: RDF::Vocab::SH.ignoredProperties
      attribute :sparql, predicate: RDF::Vocab::SH.sparql
      has_many :property, predicate: RDF::Vocab::SH.property, polymorphic: true
    end
  end
end
