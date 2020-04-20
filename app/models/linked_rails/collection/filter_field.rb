# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterField < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :key, :klass, :options, :collection

      def iri
        self
      end
      alias canonical_iri iri
    end
  end
end
