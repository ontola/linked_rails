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

      def canonical_iri; end
    end
  end
end
