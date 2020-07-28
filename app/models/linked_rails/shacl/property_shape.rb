# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyShape < LinkedRails::SHACL::Shape
      # SHACL attributes
      attr_accessor(
        :datatype,
        :default_value,
        :description,
        :disjoint,
        :equals,
        :flags,
        :group,
        :language,
        :less_than,
        :less_than_or_equals,
        :max_count,
        :max_exclusive,
        :max_inclusive,
        :max_length,
        :min_count,
        :min_exclusive,
        :min_inclusive,
        :min_length,
        :name,
        :node,
        :path,
        :pattern,
        :sh_class,
        :unique_language,
        :qualified_max_count,
        :qualified_min_count,
        :qualified_value_shape
      )
      attr_writer :has_value, :sh_in

      def has_value
        @has_value.respond_to?(:call) ? @has_value.call : @has_value
      end

      def sh_in
        @sh_in.respond_to?(:call) ? @sh_in.call : @sh_in
      end

      class << self
        def iri
          RDF::Vocab::SH.PropertyShape
        end
      end
    end
  end
end
