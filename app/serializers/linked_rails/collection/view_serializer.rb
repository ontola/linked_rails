# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :count, predicate: RDF::Vocab::AS.totalItems
      attribute :display, predicate: Vocab::ONTOLA[:collectionDisplay] do |object|
        Vocab::ONTOLA["collectionDisplay/#{object.display || :default}"]
      end

      %i[next prev].each do |attr|
        attribute attr, predicate: RDF::Vocab::AS[attr]
      end

      has_one :collection, predicate: RDF::Vocab::AS.partOf, polymorphic: true
      has_one :unfiltered_collection, predicate: Vocab::ONTOLA[:baseCollection], polymorphic: true
      has_one :member_sequence, predicate: RDF::Vocab::AS.items, polymorphic: true
    end
  end
end
