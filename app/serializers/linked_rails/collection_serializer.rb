# frozen_string_literal: true

module LinkedRails
  class CollectionSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer
    extend LinkedRails::Helpers::DeltaHelper

    attribute :base_url, predicate: Vocab.schema.url do |object|
      object.iri(display: nil, page_size: nil, table_type: nil)
    end
    attribute :title, predicate: Vocab.as.name
    attribute :total_count, predicate: Vocab.as.totalItems do |object|
      object.total_count if object.type == :paginated
    end
    attribute :iri_template, predicate: Vocab.ontola[:iriTemplate] do |object|
      object
        .iri_template
        .to_s
        .gsub('{route_key}', object.route_key.to_s)
        .gsub('{/parent_iri*}', object.parent&.iri&.to_s&.split('?')&.first || LinkedRails.iri)
    end
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
    attribute :collected_at_with_default, predicate: Vocab.ontola[:collectedAt]
    attribute :last_activity_at, predicate: Vocab.ontola[:lastActivityAt] do |object|
      object.collected_at if object.base_collection?
    end

    has_one :unfiltered_collection, predicate: Vocab.ontola[:baseCollection]
    has_one :part_of, predicate: Vocab.schema.isPartOf do |object|
      object.part_of unless object.part_of.try(:anonymous_iri?)
    end
    has_one :default_view, predicate: Vocab.ontola[:pages]

    has_many :filter_fields, predicate: Vocab.ontola[:filterFields], sequence: true
    has_many :filters, predicate: Vocab.ontola[:collectionFilter] do |object|
      object.filters.reject(&:default_filter)
    end
    has_many :sortings, predicate: Vocab.ontola[:collectionSorting]

    %i[first last].each do |attr|
      attribute attr, predicate: Vocab.as[attr]
    end
  end
end
