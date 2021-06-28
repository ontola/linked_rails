# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShape < Shape
      # SHACL attributes
      attr_accessor(
        :closed,
        :ignored_properties,
        :property,
        :sparql
      )

      class << self
        def iri
          Vocab.sh.NodeShape
        end
      end
    end
  end
end
