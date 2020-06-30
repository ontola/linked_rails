# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShapeSerializer < ShapeSerializer
      attribute :datatype, predicate: RDF::Vocab::SH.datatype
      attribute :default_value, predicate: RDF::Vocab::SH.defaultValue
      attribute :description, predicate: RDF::Vocab::SH.description
      attribute :disjoint, predicate: RDF::Vocab::SH.disjoint
      attribute :has_value, predicate: RDF::Vocab::SH.hasValue
      attribute :equals, predicate: RDF::Vocab::SH.equals
      attribute :flags, predicate: RDF::Vocab::SH.flags
      attribute :group, predicate: RDF::Vocab::SH.group
      attribute :language, predicate: RDF::Vocab::SH.languageIn
      attribute :less_than, predicate: RDF::Vocab::SH.lessThan
      attribute :less_than_or_equals, predicate: RDF::Vocab::SH.lessThanOrEquals
      attribute :max_count, predicate: RDF::Vocab::SH.maxCount
      attribute :max_exclusive, predicate: RDF::Vocab::SH.maxExclusive
      attribute :max_inclusive, predicate: RDF::Vocab::SH.maxInclusive
      attribute :max_length, predicate: RDF::Vocab::SH.maxLength
      attribute :min_count, predicate: RDF::Vocab::SH.minCount
      attribute :min_exclusive, predicate: RDF::Vocab::SH.minExclusive
      attribute :min_inclusive, predicate: RDF::Vocab::SH.minInclusive
      attribute :min_length, predicate: RDF::Vocab::SH.minLength
      attribute :name, predicate: RDF::Vocab::SH.name
      attribute :node, predicate: RDF::Vocab::SH.node
      attribute :pattern, predicate: RDF::Vocab::SH.pattern
      attribute :sh_class, predicate: RDF::Vocab::SH.class
      attribute :sh_in, predicate: RDF::Vocab::SH.in
      attribute :unique_language, predicate: RDF::Vocab::SH.uniqueLang
      attribute :qualified_max_count, predicate: RDF::Vocab::SH.qualifiedMaxCount
      attribute :qualified_min_count, predicate: RDF::Vocab::SH.qualifiedMinCount
      attribute :qualified_value_shape, predicate: RDF::Vocab::SH.qualifiedValueShape

      has_many :path, predicate: RDF::Vocab::SH.path, sequence: true
    end
  end
end
