# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: Vocab::ONTOLA[:filterKey]
      attribute :value, predicate: Vocab::ONTOLA[:filterValue]
      has_one :collection, predicate: RDF::Vocab::SCHEMA.isPartOf
    end
  end
end
