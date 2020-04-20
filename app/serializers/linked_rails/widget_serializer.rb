# frozen_string_literal: true

module LinkedRails
  class WidgetSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :size, predicate: Vocab::ONTOLA[:widgetSize]
    attribute :topology, predicate: Vocab::ONTOLA[:topology]
    has_one :resource_sequence, predicate: Vocab::ONTOLA[:widgetResource]
    has_one :parent, predicate: RDF::Vocab::SCHEMA.isPartOf
    has_many :property_shapes

    def property_shapes
      object.property_shapes.values
    end
  end
end
