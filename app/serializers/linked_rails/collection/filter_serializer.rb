# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: LinkedRails::NS::ONTOLA[:filterKey]
      attribute :value, predicate: LinkedRails::NS::ONTOLA[:filterValue]
    end
  end
end
