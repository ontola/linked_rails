# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :count, predicate: NS::AS[:totalItems]
      attribute :display, predicate: LinkedRails::NS::ONTOLA[:collectionDisplay]

      %i[first prev next last].each do |attr|
        attribute attr, predicate: NS::AS[attr]
      end

      has_one :collection, predicate: NS::AS[:partOf]
      has_one :unfiltered_collection, predicate: LinkedRails::NS::ONTOLA[:baseCollection]
      has_one :member_sequence, predicate: NS::AS[:items]

      def display
        LinkedRails::NS::ONTOLA["collectionDisplay/#{object.display || :default}"]
      end
    end
  end
end
