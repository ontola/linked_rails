# frozen_string_literal: true

module LinkedRails
  class CollectionSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :base_url, predicate: RDF::Vocab::SCHEMA.url do |object|
      object.iri(display: nil, page_size: nil)
    end
    attribute :title, predicate: RDF::Vocab::AS.name
    attribute :total_count, predicate: RDF::Vocab::AS.totalItems do |object|
      object.total_count if object.type == :paginated
    end
    attribute :iri_template, predicate: Vocab::ONTOLA[:iriTemplate]
    attribute :iri_template_opts, predicate: Vocab::ONTOLA[:iriTemplateOpts]
    attribute :default_type, predicate: Vocab::ONTOLA[:defaultType], &:type
    attribute :display, predicate: Vocab::ONTOLA[:collectionDisplay] do |object|
      Vocab::ONTOLA["collectionDisplay/#{object.display || :default}"]
    end
    attribute :columns, predicate: Vocab::ONTOLA[:columns]
    attribute :collection_type, predicate: Vocab::ONTOLA[:collectionType] do |object|
      Vocab::ONTOLA["collectionType/#{object.type || :paginated}"]
    end
    attribute :grid_max_columns, predicate: NS::ONTOLA['grid/maxColumns']
    attribute :sort_options, predicate: NS::ONTOLA[:sortOptions]
    attribute :view, predicate: NS::LL[:view]

    has_one :unfiltered_collection, predicate: Vocab::ONTOLA[:baseCollection], polymorphic: true
    has_one :part_of, predicate: RDF::Vocab::SCHEMA.isPartOf, polymorphic: true
    has_one :default_view, predicate: Vocab::ONTOLA[:pages], polymorphic: true

    has_many :filter_fields, predicate: Vocab::ONTOLA[:filterFields], polymorphic: true
    has_many :filters, predicate: Vocab::ONTOLA[:collectionFilter], polymorphic: true do |object|
      object.filters.reject(&:default_filter)
    end
    has_many :sortings, polymorphic: true, predicate: Vocab::ONTOLA[:collectionSorting]

    %i[first last].each do |attr|
      attribute attr, predicate: RDF::Vocab::AS[attr]
    end
  end
end
