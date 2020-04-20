# frozen_string_literal: true

module LinkedRails
  class Collection
    class SortingSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: Vocab::ONTOLA[:sortKey]
      attribute :direction, predicate: Vocab::ONTOLA[:sortDirection]
      has_one :collection, predicate: RDF::Vocab::SCHEMA.isPartOf
    end
  end
end
