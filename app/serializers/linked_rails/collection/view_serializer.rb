# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :count, predicate: Vocab.as.totalItems
      attribute :display, predicate: Vocab.ontola[:collectionDisplay] do |object|
        Vocab.ontola["collectionDisplay/#{object.display || :default}"]
      end

      %i[next prev].each do |attr|
        attribute attr, predicate: Vocab.as[attr]
      end

      has_one :collection, predicate: Vocab.as.partOf
      has_one :unfiltered_collection, predicate: Vocab.ontola[:baseCollection]
      has_one :member_sequence, predicate: Vocab.as.items
    end
  end
end
