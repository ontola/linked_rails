# frozen_string_literal: true

module LinkedRails
  module Serializer
    module Singularable
      extend ActiveSupport::Concern

      included do
        statements :same_as_statement

        def self.same_as_statement(object, _params)
          return [] unless object.try(:singular_resource?) && object.singular_iri != object.iri

          [
            RDF::Statement.new(
              object.singular_iri,
              Vocab.owl.sameAs,
              object.iri,
              graph_name: Vocab.ld[:supplant]
            )
          ]
        end
      end
    end
  end
end
