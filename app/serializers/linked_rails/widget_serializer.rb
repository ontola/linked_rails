# frozen_string_literal: true

module LinkedRails
  class WidgetSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :size, predicate: Vocab::ONTOLA[:widgetSize]
    attribute :topology, predicate: Vocab::ONTOLA[:topology]
    has_one :resource_sequence, predicate: Vocab::ONTOLA[:widgetResource], polymorphic: true
    has_one :parent, predicate: RDF::Vocab::SCHEMA.isPartOf, polymorphic: true
    has_many :property_shapes, polymorphic: true do |object|
      object.property_shapes.values
    end
  end
end
