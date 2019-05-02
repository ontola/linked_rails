# frozen_string_literal: true

module LinkedRails
  module SHACL
    class PropertyGroupSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :description, predicate: NS::SH[:description]
      attribute :label, predicate: RDF::RDFS[:label]
      attribute :order, predicate: NS::SH[:order]

      def type
        NS::SH[:PropertyGroup]
      end
    end
  end
end
