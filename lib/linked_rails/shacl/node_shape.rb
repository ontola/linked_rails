# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShape < Shape
      attr_accessor :closed,
                    :or,
                    :not,
                    :property,
                    :form_steps

      def self.iri
        NS::SH[:NodeShape]
      end
    end
  end
end
