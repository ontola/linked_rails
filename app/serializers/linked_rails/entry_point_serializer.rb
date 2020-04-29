# frozen_string_literal: true

module LinkedRails
  class EntryPointSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :label, predicate: RDF::Vocab::SCHEMA.name
    attribute :description, predicate: RDF::Vocab::SCHEMA.text
    attribute :url, predicate: RDF::Vocab::SCHEMA.url
    attribute :http_method, key: :method, predicate: RDF::Vocab::SCHEMA.httpMethod do |object|
      object.http_method.upcase
    end

    has_one :parent, predicate: RDF::Vocab::SCHEMA.isPartOf, polymorphic: true
    has_one :action_body, predicate: Vocab::LL[:actionBody], polymorphic: true
    attribute :image, predicate: RDF::Vocab::SCHEMA.image do |object|
      serialize_image(object.image)
    end
  end
end
