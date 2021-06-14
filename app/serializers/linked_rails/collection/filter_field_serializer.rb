# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterFieldSerializer < LinkedRails.serializer_parent_class
      attribute :key, predicate: NS::ONTOLA[:filterKey]
      attribute :options_in, predicate: NS::ONTOLA[:filterOptionsIn]
      has_one :collection, predicate: NS::SCHEMA.isPartOf
      has_many :options, predicate: NS::ONTOLA[:filterOptions]
    end
  end
end
