# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterOptionSerializer < LinkedRails.serializer_parent_class
      attribute :count, predicate: Vocab.ontola[:filterCount]
      attribute :key, predicate: Vocab.ontola[:filterKey]
      attribute :value, predicate: Vocab.ontola[:filterValue]
      has_one :collection, predicate: Vocab.schema[:isPartOf]
    end
  end
end
