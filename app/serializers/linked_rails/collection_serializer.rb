# frozen_string_literal: true

module LinkedRails
  class CollectionSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :base_url, predicate: LinkedRails::NS::SCHEMA[:url]
    attribute :title, predicate: NS::AS[:name]
    attribute :total_count, predicate: NS::AS[:totalItems]
    attribute :iri_template, predicate: LinkedRails::NS::ONTOLA[:iriTemplate]
    attribute :default_type, predicate: LinkedRails::NS::ONTOLA[:defaultType]
    attribute :display, predicate: LinkedRails::NS::ONTOLA[:collectionDisplay]
    attribute :columns, predicate: LinkedRails::NS::ONTOLA[:columns]
    attribute :collection_type, predicate: LinkedRails::NS::ONTOLA[:collectionType]

    has_one :unfiltered_collection, predicate: LinkedRails::NS::ONTOLA[:baseCollection]
    has_one :part_of, predicate: NS::SCHEMA[:isPartOf]
    has_one :default_view, predicate: NS::AS[:pages]
    has_many :default_filtered_collections, predicate: LinkedRails::NS::ONTOLA[:filteredCollections]

    has_many :filters, predicate: LinkedRails::NS::ONTOLA[:collectionFilter]
    has_many :sortings, predicate: LinkedRails::NS::ONTOLA[:collectionSorting]

    delegate :filtered?, to: :object

    %i[first last].each do |attr|
      attribute attr, predicate: NS::AS[attr]
    end

    def base_url
      object.iri(display: nil, page_size: nil)
    end

    def collection_type
      NS::ONTOLA["collectionType/#{object.type || :paginated}"]
    end

    def columns
      case object.display
      when 'table'
        columns_list = object.association_class.try(:defined_columns).try(:[], :default)
      when 'settingsTable'
        columns_list = object.association_class.try(:defined_columns).try(:[], :settings)
      end
      RDF::List[*columns_list] if columns_list.present?
    end

    def default_type
      object.type
    end

    def display
      LinkedRails::NS::ONTOLA["collectionDisplay/#{object.display || :default}"]
    end

    def type
      return object.class.iri unless object.filtered?

      LinkedRails::NS::ONTOLA[:FilteredCollection]
    end
  end
end
