# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewSerializer < ActiveModel::Serializer
      include LinkedRails::Serializer

      attribute :count, predicate: NS::AS[:totalItems]

      %i[first prev next last].each do |attr|
        attribute attr, predicate: NS::AS[attr]
      end

      has_one :collection, predicate: NS::AS[:partOf]
      has_one :collection, predicate: LinkedRails::NS::ONTOLA[:baseCollection]
      has_one :member_sequence, predicate: NS::AS[:items]
    end
  end
end
