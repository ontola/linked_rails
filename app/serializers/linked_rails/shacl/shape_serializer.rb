# frozen_string_literal: true

module LinkedRails
  module SHACL
    class ShapeSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :deactivated, predicate: RDF::Vocab::SH.deactivated
      attribute :message, predicate: RDF::Vocab::SH.message
      attribute :node_kind, predicate: RDF::Vocab::SH.nodeKind
      attribute :severity, predicate: RDF::Vocab::SH.severity
      attribute :target_class, predicate: RDF::Vocab::SH.targetClass
      attribute :target_node, predicate: RDF::Vocab::SH.targetNode
      attribute :target_objects_of, predicate: RDF::Vocab::SH.targetObjectsOf
      attribute :target_subjects_of, predicate: RDF::Vocab::SH.targetSubjectsOf
      has_one :sh_not, predicate: RDF::Vocab::SH.not
      has_many :and, predicate: RDF::Vocab::SH.and
      has_many :or, predicate: RDF::Vocab::SH.or
      has_many :xone, predicate: RDF::Vocab::SH.xone
      has_many :nested_shapes do |object|
        [object.and, object.or, object.sh_not, object.xone].flatten.compact
      end
    end
  end
end
