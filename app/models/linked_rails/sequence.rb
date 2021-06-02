# frozen_string_literal: true

module LinkedRails
  class Sequence
    attr_accessor :node, :parent, :raw_members, :scope, :user_context
    alias read_attribute_for_serialization send

    def initialize(members, id: nil, parent: nil, scope: nil, user_context: nil)
      self.node = id || RDF::Node.new
      self.raw_members = members
      self.parent = parent
      self.scope = scope
      self.user_context = user_context
    end

    def iri(_opts = {})
      node
    end
    alias id iri

    def members
      @members ||= apply_scope(
        raw_members.respond_to?(:call) ? raw_members.call : raw_members
      )
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

    def apply_scope(association)
      return association if scope == false

      policy_scope = scope || Pundit::PolicyFinder.new(association).scope!

      policy_scope.new(user_context, association).resolve
    end

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
