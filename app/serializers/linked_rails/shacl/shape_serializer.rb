# frozen_string_literal: true

module LinkedRails
  module SHACL
    class ShapeSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :deactivated, predicate: NS::SH[:deactivated]
      attribute :label, predicate: RDF::RDFS[:label]
      attribute :message, predicate: NS::SH[:message]
      attribute :severity, predicate: NS::SH[:severity]
      attribute :sparql, predicate: NS::SH[:sparql]
      attribute :target, predicate: NS::SH[:target]
      attribute :target_class, predicate: NS::SH[:targetClass]
      attribute :target_node, predicate: NS::SH[:targetNode]
      attribute :target_objects_of, predicate: NS::SH[:targetObjectsOf]
      attribute :target_subjects_of, predicate: NS::SH[:targetSubjectsOf]

      has_many :referred_shapes, predicate: LinkedRails::NS::ONTOLA[:referredShapes]

      def referred_shapes
        object.referred_shapes&.map do |shape|
          if shape.is_a?(Class) && shape < LinkedRails::Form
            build_shape(shape)
          else
            shape
          end
        end
      end

      private

      def build_shape(shape)
        shape.new(object.form.target.build_child(shape.model_class), object.form.iri_template, scope).shape
      end
    end
  end
end
