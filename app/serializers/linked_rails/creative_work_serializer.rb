# frozen_string_literal: true

module LinkedRails
  class CreativeWorkSerializer < LinkedRails.serializer_parent_class
    attribute :description, predicate: LinkedRails::RDF::Vocab::SCHEMA.description
    attribute :name, predicate: RDF::Vocab::SCHEMA.name
    attribute :text, predicate: RDF::Vocab::SCHEMA.text
    attribute :url, predicate: RDF::Vocab::SCHEMA.url
  end
end
