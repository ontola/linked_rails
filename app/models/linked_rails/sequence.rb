# frozen_string_literal: true

module LinkedRails
  class Sequence
    attr_accessor :node
    attr_writer :members
    alias read_attribute_for_serialization send

    def initialize(members, id: nil)
      self.node = id || RDF::Node.new
      self.members = members
    end

    def iri
      node
    end
    alias id iri

    def members
      @members = @members.respond_to?(:call) ? @members.call : @members
    end

    def rdf_type
      self.class.iri
    end

    def sequence
      return [] unless members

      members.map.with_index do |item, index|
        [iri, RDF["_#{index}"], item_iri(item), Vocab::LL[:supplant]]
      end
    end

    private

    def item_iri(item)
      item.is_a?(RDF::Resource) ? item : item.iri
    end

    class << self
      def iri
        RDF[:Seq]
      end
    end
  end
end
