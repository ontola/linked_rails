# frozen_string_literal: true

module LinkedRails
  class Collection
    class Filter < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :key, :value

      def iri
        self
      end
    end
  end
end
