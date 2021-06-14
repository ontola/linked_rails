# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterOption < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :collection, :count, :value, :key

      def iri(_opts = {})
        self
      end

      def canonical_iri; end
    end
  end
end
