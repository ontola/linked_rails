# frozen_string_literal: true

module LinkedRails
  class Collection
    class ViewSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :count, predicate: RDF::Vocab::AS.totalItems
      attribute :display, predicate: Vocab::ONTOLA[:collectionDisplay]

      %i[next prev].each do |attr|
        attribute attr, predicate: RDF::Vocab::AS[attr]
      end

      has_one :collection, predicate: RDF::Vocab::AS.partOf
      has_one :unfiltered_collection, predicate: Vocab::ONTOLA[:baseCollection]
      has_one :member_sequence, predicate: RDF::Vocab::AS.items

      def display
        Vocab::ONTOLA["collectionDisplay/#{object.display || :default}"]
      end
    end
  end
end
