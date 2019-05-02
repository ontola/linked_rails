# frozen_string_literal: true

module LinkedRails
  class Collection
    class Sorting < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :association_class, :direction, :key

      def iri
        self
      end

      def sort_value
        {attribute_name => direction}
      end

      private

      def attribute_name
        @attribute_name ||= association_class.try(:predicate_mapping).try(:[], key)&.name || :created_at
      end

      class << self
        def from_array(association_class, array)
          array&.map do |sort|
            new(
              association_class: association_class,
              direction: sort[:direction],
              key: sort[:key]
            )
          end
        end
      end
    end
  end
end
