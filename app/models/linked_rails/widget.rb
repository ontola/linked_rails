# frozen_string_literal: true

module LinkedRails
  class Widget
    include ActiveModel::Model
    include LinkedRails::Model

    attr_writer :resources, :size
    attr_accessor :parent, :topology

    def iri(_opts = {})
      @iri ||= RDF::Node.new
    end

    def property_shapes
      resource_sequence

      @property_shapes || {}
    end

    def resource_sequence
      @resource_sequence ||=
        LinkedRails::Sequence.new(
          @resources.map { |iri, predicate| predicate.present? ? property_shape(iri, predicate).iri : RDF::URI(iri) },
          parent: self,
          scope: false
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
          target_node: iri.is_a?(RDF::Resource) ? iri : RDF::URI(iri),
          path: RDF::URI(predicate)
        )
    end

    class << self
      def iri
        Vocab.ontola[:Widget]
      end

      def preview_includes
        %i[resource_sequence property_shapes]
      end
    end
  end
end
