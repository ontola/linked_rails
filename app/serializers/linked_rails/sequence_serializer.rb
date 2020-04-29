# frozen_string_literal: true

module LinkedRails
  class SequenceSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    statements :sequence
    has_many :members, polymorphic: true

    def self.sequence(object, _params)
      return [] unless object.members

      object.members.map.with_index do |item, index|
        [object.iri, RDF["_#{index}"], item_iri(item), Vocab::LL[:supplant]]
      end
    end

    def self.item_iri(item)
      item.is_a?(RDF::Resource) ? item : item.iri
    end
  end
end
