# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShapeSerializer < ShapeSerializer
      include LinkedRails::Serializer

      attribute :datatype, predicate: NS::SH[:datatype]
      attribute :default_value, predicate: NS::SH[:defaultValue]
      attribute :description, predicate: NS::SH[:description]
      attribute :group, predicate: NS::SH[:group]
      attribute :max_count, predicate: NS::SH[:maxCount]
      attribute :min_count, predicate: NS::SH[:minCount]
      attribute :max_length, predicate: NS::SH[:maxLength]
      attribute :min_length, predicate: NS::SH[:minLength]
      attribute :name, predicate: NS::SH[:name]
      attribute :node, predicate: NS::SH[:node]
      attribute :node_kind, predicate: NS::SH[:nodeKind]
      attribute :order, predicate: NS::SH[:order]
      attribute :pattern, predicate: NS::SH[:pattern]
      attribute :sh_class, predicate: NS::SH[:class]
      attribute :sh_in, predicate: NS::SH[:in]
      attribute :path, predicate: NS::SH[:path]

      has_many :sh_in_options

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
        options = sh_in_options
        return options unless [Array, ActiveRecord::Relation].any? { |klass| options.is_a?(klass) }

        RDF::List[*options.map { |option| option.try(:iri) || option }]
      end

      def sh_in_options
        object.sh_in
      end
    end
  end
end
