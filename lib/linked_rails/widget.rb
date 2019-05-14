# frozen_string_literal: true

module LinkedRails
  class Widget
    include ActiveModel::Model
    include ActiveModel::Serialization
    include LinkedRails::Model

    attr_writer :resources, :size
    attr_accessor :parent

    def iri
      @iri ||= RDF::Node.new
    end

    def property_shapes
      @property_shapes || {}
    end

    def resource_sequence
      @resource_sequence ||=
        LinkedRails::Sequence.new(
          @resources
            .map { |iri, predicate| predicate.present? ? property_shape(iri, predicate).iri : RDF::URI(iri) }
        )
    end

    def size
      @size || 1
    end

    private

    def property_shape(iri, predicate)
      @property_shapes ||= {}
      @property_shapes[[iri, predicate]] ||=
        LinkedRails::PropertyQuery.new(
          target_node: RDF::URI(iri),
          path: RDF::URI(predicate)
        )
    end

    class << self
      def iri
        LinkedRails::NS::ONTOLA[:Widget]
      end

      def preview_includes
        %i[resource_sequence property_shapes]
      end
    end
  end
end
