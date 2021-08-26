# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShapeSerializer < ShapeSerializer
      attribute :datatype, predicate: Vocab.sh.datatype
      attribute :default_value, predicate: Vocab.sh.defaultValue
      attribute :description, predicate: Vocab.sh.description
      attribute :disjoint, predicate: Vocab.sh.disjoint
      attribute :has_value, predicate: Vocab.sh.hasValue
      attribute :equals, predicate: Vocab.sh.equals
      attribute :flags, predicate: Vocab.sh.flags
      attribute :group, predicate: Vocab.sh.group
      attribute :language, predicate: Vocab.sh.languageIn
      attribute :less_than, predicate: Vocab.sh.lessThan
      attribute :less_than_or_equals, predicate: Vocab.sh.lessThanOrEquals
      attribute :max_count, predicate: Vocab.sh.maxCount
      attribute :max_exclusive, predicate: Vocab.sh.maxExclusive
      attribute :max_inclusive, predicate: Vocab.sh.maxInclusive
      attribute :max_length, predicate: Vocab.sh.maxLength
      attribute :min_count, predicate: Vocab.sh.minCount
      attribute :min_exclusive, predicate: Vocab.sh.minExclusive
      attribute :min_inclusive, predicate: Vocab.sh.minInclusive
      attribute :min_length, predicate: Vocab.sh.minLength
      attribute :name, predicate: Vocab.sh.name
      attribute :node, predicate: Vocab.sh.node
      attribute :pattern, predicate: Vocab.sh.pattern
      attribute :sh_class, predicate: Vocab.sh.class
      attribute :sh_in, predicate: Vocab.sh.in
      attribute :unique_language, predicate: Vocab.sh.uniqueLang
      attribute :qualified_max_count, predicate: Vocab.sh.qualifiedMaxCount
      attribute :qualified_min_count, predicate: Vocab.sh.qualifiedMinCount
      attribute :qualified_value_shape, predicate: Vocab.sh.qualifiedValueShape

      has_many :path, predicate: Vocab.sh.path, sequence: true, polymorphic: true
    end
  end
end
