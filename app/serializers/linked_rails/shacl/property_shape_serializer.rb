# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShapeSerializer < ShapeSerializer
      include LinkedRails::Serializer

      attribute :datatype, predicate: RDF::Vocab::SH.datatype
      attribute :default_value, predicate: RDF::Vocab::SH.defaultValue
      attribute :description, predicate: RDF::Vocab::SH.description
      attribute :group, predicate: RDF::Vocab::SH.group
      attribute :helper_text, predicate: Vocab::ONTOLA[:helperText]
      attribute :input_field, predicate: Vocab::ONTOLA[:inputFieldHint]
      attribute :max_count, predicate: RDF::Vocab::SH.maxCount
      attribute :min_count, predicate: RDF::Vocab::SH.minCount
      attribute :max_length, predicate: RDF::Vocab::SH.maxLength
      attribute :min_length, predicate: RDF::Vocab::SH.minLength
      attribute :name, predicate: RDF::Vocab::SH.name
      attribute :node, predicate: RDF::Vocab::SH.node
      attribute :node_kind, predicate: RDF::Vocab::SH.nodeKind
      attribute :order, predicate: RDF::Vocab::SH.order
      attribute :pattern, predicate: RDF::Vocab::SH.pattern
      attribute :sh_class, predicate: RDF::Vocab::SH.class
      attribute :sh_in, predicate: RDF::Vocab::SH.in
      attribute :path, predicate: RDF::Vocab::SH.path

      def default_value
        if object.default_value.respond_to?(:call)
          object.form.instance_exec(&object.default_value)
        else
          object.default_value
        end
      end

      def pattern
        object.pattern.is_a?(Regexp) ? object.pattern.source : object.pattern
      end

      def sh_in
        options = object.sh_in
        return options unless [Array, ActiveRecord::Relation].any? { |klass| options.is_a?(klass) }

        RDF::List[*options.map { |option| option.try(:iri) || option }]
      end
    end
  end
end
