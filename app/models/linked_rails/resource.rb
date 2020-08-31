# frozen_string_literal: true

module LinkedRails
  class Resource
    include ActiveModel::Model
    include ActiveModel::Attributes

    include LinkedRails::Model

    attr_accessor :iri
    alias_attribute :id, :iri

    def canonical_iri
      iri unless iri.anonymous?
    end

    def initialize(attrs = {})
      super(attrs)
      @iri ||= RDF::Node.new
    end
  end
end
