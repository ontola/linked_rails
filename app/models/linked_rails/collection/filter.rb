# frozen_string_literal: true

module LinkedRails
  class Collection
    class Filter < RDF::Node
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :default_filter, :key, :value, :collection

      def iri(_opts = {})
        self
      end
    end
  end
end
