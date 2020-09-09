# frozen_string_literal: true

module LinkedRails
  class Form
    class FieldSerializer < LinkedRails.serializer_parent_class
      attribute :name, predicate: RDF::Vocab::SCHEMA.name
      attribute :description, predicate: RDF::Vocab::SCHEMA.text
      attribute :helper_text, predicate: Vocab::ONTOLA[:helperText]

      attribute :datatype, predicate: RDF::Vocab::SH.datatype
      attribute :max_count, predicate: RDF::Vocab::SH.maxCount
      attribute :max_count_prop, predicate: Vocab::ONTOLA[:maxCount]
      attribute :min_count, predicate: RDF::Vocab::SH.minCount
      attribute :min_count_prop, predicate: Vocab::ONTOLA[:minCount]
      attribute :max_inclusive, predicate: RDF::Vocab::SH.maxInclusive
      attribute :max_inclusive_prop, predicate: Vocab::ONTOLA[:maxInclusive]
      attribute :min_inclusive, predicate: RDF::Vocab::SH.minInclusive
      attribute :min_inclusive_prop, predicate: Vocab::ONTOLA[:minInclusive]
      attribute :max_length, predicate: RDF::Vocab::SH.maxLength
      attribute :max_length_prop, predicate: Vocab::ONTOLA[:maxLength]
      attribute :min_length, predicate: RDF::Vocab::SH.minLength
      attribute :min_length_prop, predicate: Vocab::ONTOLA[:minLength]
      attribute :pattern, predicate: RDF::Vocab::SH.pattern do |object|
        object.pattern.is_a?(Regexp) ? object.pattern.source : object.pattern
      end
      attribute :sh_in, predicate: RDF::Vocab::SH.in do |object|
        options = object.sh_in
        if [Array, ActiveRecord::Relation].any? { |klass| options.is_a?(klass) }
          RDF::List[*options.map { |option| option.try(:iri) || option }]
        else
          options
        end
      end
      attribute :path, predicate: RDF::Vocab::SH.path
    end
  end
end
