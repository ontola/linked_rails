# frozen_string_literal: true

module LinkedRails
  class CollectionSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :base_url, predicate: Vocab.schema.url do |object|
      object.iri(display: nil, page_size: nil)
    end
    attribute :title, predicate: Vocab.as.name
    attribute :total_count, predicate: Vocab.as.totalItems do |object|
      object.total_count if object.type == :paginated
    end
    attribute :serialized_iri_template, predicate: Vocab.ontola[:iriTemplate]
    attribute :iri_template_opts, predicate: Vocab.ontola[:iriTemplateOpts]
    attribute :download_urls, predicate: Vocab.schema.downloadUrl
    attribute :default_type, predicate: Vocab.ontola[:defaultType], &:type
    attribute :display, predicate: Vocab.ontola[:collectionDisplay] do |object|
      Vocab.ontola["collectionDisplay/#{object.display || :default}"]
    end
    attribute :call_to_action, predicate: Vocab.ontola[:callToAction]
    attribute :columns, predicate: Vocab.ontola[:columns]
    attribute :collection_type, predicate: Vocab.ontola[:collectionType] do |object|
      Vocab.ontola["collectionType/#{object.type || :paginated}"]
    end
    attribute :grid_max_columns, predicate: Vocab.ontola['grid/maxColumns']
    attribute :sort_options, predicate: Vocab.ontola[:sortOptions]
    attribute :view, predicate: Vocab.ll[:view]

    has_one :unfiltered_collection, predicate: Vocab.ontola[:baseCollection]
    has_one :part_of, predicate: Vocab.schema.isPartOf do |object|
      object.part_of unless object.part_of.try(:anonymous_iri?)
    end
    has_one :default_view, predicate: Vocab.ontola[:pages]

    has_many :filter_fields, predicate: Vocab.ontola[:filterFields], sequence: true
    has_many :filters, predicate: Vocab.ontola[:activeFilters] do |object|
      object.filters.reject(&:default_filter)
    end
    has_many :sortings, predicate: Vocab.ontola[:collectionSorting]

    %i[first last].each do |attr|
      attribute attr, predicate: Vocab.as[attr]
    end
  end
end
