# frozen_string_literal: true

module LinkedRails
  class SequenceSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    triples :sequence
    has_many :members

    def type
      RDF[:Seq]
    end

    def sequence
      object&.members&.map&.with_index { |item, index| [rdf_subject, RDF["_#{index}"], item_iri(item)] } || []
    end

    def rdf_subject
      object.node
    end

    private

    def item_iri(item)
      item.is_a?(RDF::Resource) ? item : item.iri
    end
  end
end
