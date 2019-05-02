# frozen_string_literal: true

module LinkedRails
  module SHACL
    class NodeShapeSerializer < ShapeSerializer
      include LinkedRails::Serializer

      attribute :closed, predicate: NS::SH[:closed]
      attribute :or, predicate: NS::SH[:or]
      attribute :not, predicate: NS::SH[:not]

      has_many :property, predicate: NS::SH[:property]
      has_many :form_steps, predicate: NS::ONTOLA[:formSteps]

      def type
        NS::SH[:NodeShape]
      end
    end
  end
end
