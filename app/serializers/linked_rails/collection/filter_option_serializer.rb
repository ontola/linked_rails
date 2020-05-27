# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterOptionSerializer < LinkedRails.serializer_parent_class
      attribute :count, predicate: NS::ONTOLA[:filterCount]
      attribute :key, predicate: NS::ONTOLA[:filterKey]
      attribute :value, predicate: NS::ONTOLA[:filterValue]
      has_one :collection, predicate: NS::SCHEMA[:isPartOf]
    end
  end
end
