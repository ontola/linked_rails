# frozen_string_literal: true

module LinkedRails
  module SHACL
    class ShapeSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :deactivated, predicate: RDF::Vocab::SH.deactivated
      attribute :label, predicate: RDF::RDFS[:label]
      attribute :message, predicate: RDF::Vocab::SH.message
      attribute :severity, predicate: RDF::Vocab::SH.severity
      attribute :sparql, predicate: RDF::Vocab::SH.sparql
      attribute :target, predicate: RDF::Vocab::SH.target
      attribute :target_class, predicate: RDF::Vocab::SH.targetClass
      attribute :target_node, predicate: RDF::Vocab::SH.targetNode
      attribute :target_objects_of, predicate: RDF::Vocab::SH.targetObjectsOf
      attribute :target_subjects_of, predicate: RDF::Vocab::SH.targetSubjectsOf

      has_many :referred_shapes, predicate: Vocab::ONTOLA[:referredShapes]

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
