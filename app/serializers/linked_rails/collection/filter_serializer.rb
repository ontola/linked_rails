# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterSerializer < ActiveModel::Serializer
      include LinkedRails::Serializer

      attribute :key, predicate: LinkedRails::NS::ONTOLA[:filterKey]
      attribute :value, predicate: LinkedRails::NS::ONTOLA[:filterValue]
    end
  end
end
