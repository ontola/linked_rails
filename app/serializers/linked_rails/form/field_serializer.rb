# frozen_string_literal: true

module LinkedRails
  class Form
    class FieldSerializer < LinkedRails.serializer_parent_class
      attribute :name, predicate: Vocab.schema.name
      attribute :description, predicate: Vocab.schema.text
      attribute :helper_text, predicate: Vocab.form[:helperText]
      attribute :start_adornment, predicate: Vocab.form[:startAdornment]
      attribute :placeholder, predicate: Vocab.form[:placeholder]
      attribute :default_value, predicate: Vocab.form[:defaultValue]

      attribute :datatype, predicate: Vocab.sh.datatype
      attribute :max_count, predicate: Vocab.sh.maxCount
      attribute :max_count_prop, predicate: Vocab.ontola[:maxCount]
      attribute :min_count, predicate: Vocab.sh.minCount
      attribute :min_count_prop, predicate: Vocab.ontola[:minCount]
      attribute :max_inclusive, predicate: Vocab.sh.maxInclusive
      attribute :max_inclusive_prop, predicate: Vocab.ontola[:maxInclusive]
      attribute :min_inclusive, predicate: Vocab.sh.minInclusive
      attribute :min_inclusive_prop, predicate: Vocab.ontola[:minInclusive]
      attribute :max_length, predicate: Vocab.sh.maxLength
      attribute :max_length_prop, predicate: Vocab.ontola[:maxLength]
      attribute :min_length, predicate: Vocab.sh.minLength
      attribute :min_length_prop, predicate: Vocab.ontola[:minLength]
      attribute :pattern, predicate: Vocab.sh.pattern do |object|
        object.pattern.is_a?(Regexp) ? object.pattern.source : object.pattern
      end
      attribute :sh_in, predicate: Vocab.sh.in do |object|
        options = object.sh_in
        if [Array, ActiveRecord::Relation].any? { |klass| options.is_a?(klass) }
          RDF::List[*options.map { |option| option.try(:iri) || option }]
        else
          options
        end
      end
      attribute :sh_in_prop, predicate: Vocab.ontola[:shIn]
      attribute :path, predicate: Vocab.sh.path
    end
  end
end
