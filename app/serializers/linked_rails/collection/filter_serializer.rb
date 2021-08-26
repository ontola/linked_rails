# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: Vocab.ontola[:filterKey]
      attribute :value, predicate: Vocab.ontola[:filterValue]
      has_one :collection, predicate: Vocab.schema.isPartOf, polymorphic: true
    end
  end
end
