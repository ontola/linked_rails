# frozen_string_literal: true

module LinkedRails
  class Collection
    class SortingSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :key, predicate: LinkedRails::NS::ONTOLA[:sortKey]
      attribute :direction, predicate: LinkedRails::NS::ONTOLA[:sortDirection]
    end
  end
end
