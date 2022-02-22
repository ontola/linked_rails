# frozen_string_literal: true

module LinkedRails
  class Sequence
    attr_accessor :node, :parent, :raw_members, :scope, :user_context
    alias read_attribute_for_serialization send

    def initialize(members, **opts)
      self.node = opts[:id] || RDF::Node.new
      self.parent = opts[:parent]
      self.raw_members = members
      self.scope = opts[:scope]
      self.user_context = opts[:user_context]
    end

    def iri(**_opts)
      node
    end
    alias id iri

    def members
      @members ||= apply_scope(
        raw_members.respond_to?(:call) ? raw_members.call : raw_members
      )
    end

    def preview_includes
      [:members]
    end

    def rdf_type
      self.class.iri
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
