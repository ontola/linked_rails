# frozen_string_literal: true

module LinkedRails
  class WidgetSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :size, predicate: NS::ONTOLA[:widgetSize]
    has_one :resource_sequence, predicate: NS::ONTOLA[:widgetResource]
    has_one :parent, predicate: NS::SCHEMA[:isPartOf]
    has_many :property_shapes

    def property_shapes
      object.property_shapes.values
    end
  end
end
