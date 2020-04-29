# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShapeSerializer < ShapeSerializer
      include LinkedRails::Serializer

      attribute :closed, predicate: RDF::Vocab::SH.closed
      attribute :or, predicate: RDF::Vocab::SH.or
      attribute :not, predicate: RDF::Vocab::SH.not

      has_many :property, predicate: RDF::Vocab::SH.property, polymorphic: true
      has_many :form_steps, predicate: Vocab::ONTOLA[:formSteps], polymorphic: true
    end
  end
end
