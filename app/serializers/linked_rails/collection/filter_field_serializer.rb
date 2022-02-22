# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterFieldSerializer < LinkedRails.serializer_parent_class
      attribute :key, predicate: Vocab.ontola[:filterKey]
      attribute :options_in, predicate: Vocab.ontola[:filterOptionsIn]
      has_one :collection, predicate: Vocab.schema.isPartOf
      has_many :options, predicate: Vocab.ontola[:filterOptions]
    end
  end
end
