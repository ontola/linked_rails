# frozen_string_literal: true

module LinkedRails
  class CollectionSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :base_url, predicate: LinkedRails::RDF::Vocab::SCHEMA.url
    attribute :title, predicate: RDF::Vocab::AS.name
    attribute :total_count, predicate: RDF::Vocab::AS.totalItems, if: :paginated?
    attribute :iri_template, predicate: Vocab::ONTOLA[:iriTemplate]
    attribute :default_type, predicate: Vocab::ONTOLA[:defaultType]
    attribute :display, predicate: Vocab::ONTOLA[:collectionDisplay]
    attribute :columns, predicate: Vocab::ONTOLA[:columns]
    attribute :collection_type, predicate: Vocab::ONTOLA[:collectionType]

    has_one :unfiltered_collection, predicate: Vocab::ONTOLA[:baseCollection]
    has_one :part_of, predicate: RDF::Vocab::SCHEMA.isPartOf
    has_one :default_view, predicate: RDF::Vocab::AS.pages
    has_many :default_filtered_collections, predicate: Vocab::ONTOLA[:filteredCollections]

    has_many :filters, predicate: Vocab::ONTOLA[:collectionFilter]
    has_many :sortings, predicate: Vocab::ONTOLA[:collectionSorting]

    delegate :filtered?, to: :object

    %i[first last].each do |attr|
      attribute attr, predicate: RDF::Vocab::AS[attr]
    end

    def base_url
      object.iri(display: nil, page_size: nil)
    end

    def collection_type
      Vocab::ONTOLA["collectionType/#{object.type || :paginated}"]
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
      Vocab::ONTOLA["collectionDisplay/#{object.display || :default}"]
    end

    def type
      return object.class.iri unless object.filtered?

      Vocab::ONTOLA[:FilteredCollection]
    end

    def paginated?
      object.type == :paginated
    end
  end
end
