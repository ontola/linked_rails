# frozen_string_literal: true

module LinkedRails
  class Collection
    class SortingSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: Vocab.ontola[:sortKey]
      attribute :direction, predicate: Vocab.ontola[:sortDirection]
      has_one :collection, predicate: Vocab.schema.isPartOf, polymorphic: true
    end
  end
end
