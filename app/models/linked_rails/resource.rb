# frozen_string_literal: true

module LinkedRails
  class Resource
    include ActiveModel::Model
    include ActiveModel::Attributes

    include LinkedRails::Model

    attr_writer :iri
    alias_attribute :id, :iri

    def anonymous_iri?
      true
    end

    def canonical_iri
      iri unless iri.anonymous?
    end
  end
end
