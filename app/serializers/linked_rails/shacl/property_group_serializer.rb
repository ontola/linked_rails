# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyGroupSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :description, predicate: RDF::Vocab::SH.description
      attribute :label, predicate: RDF::RDFS[:label]
      attribute :order, predicate: RDF::Vocab::SH.order

      def type
        RDF::Vocab::SH.PropertyGroup
      end
    end
  end
end
