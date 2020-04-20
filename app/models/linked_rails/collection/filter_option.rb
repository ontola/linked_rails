# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterOption < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :collection, :count, :value, :key

      def iri
        self
      end
      alias canonical_iri iri
    end
  end
end
