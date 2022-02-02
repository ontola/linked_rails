# frozen_string_literal: true

module LinkedRails
  module SHACL
    class ShapeSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :deactivated, predicate: Vocab.sh.deactivated
      attribute :message, predicate: Vocab.sh.message
      attribute :node_kind, predicate: Vocab.sh.nodeKind
      attribute :severity, predicate: Vocab.sh.severity
      attribute :target_class, predicate: Vocab.sh.targetClass
      attribute :target_node, predicate: Vocab.sh.targetNode
      attribute :target_objects_of, predicate: Vocab.sh.targetObjectsOf
      attribute :target_subjects_of, predicate: Vocab.sh.targetSubjectsOf
      has_one :sh_not, predicate: Vocab.sh.not
      has_many :and, predicate: Vocab.sh.and
      has_many :or, predicate: Vocab.sh.or
      has_many :xone, predicate: Vocab.sh.xone
      has_many :nested_shapes do |object|
        [object.and, object.or, object.sh_not, object.xone].flatten.compact
      end
    end
  end
end
