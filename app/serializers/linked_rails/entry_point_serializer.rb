# frozen_string_literal: true

module LinkedRails
  class EntryPointSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :label, predicate: RDF::Vocab::SCHEMA.name
    attribute :description, predicate: RDF::Vocab::SCHEMA.text
    attribute :url, predicate: RDF::Vocab::SCHEMA.url
    attribute :http_method, key: :method, predicate: RDF::Vocab::SCHEMA.httpMethod
    attribute :image, predicate: RDF::Vocab::SCHEMA.image

    has_one :action_body, predicate: Vocab::LL[:actionBody]

    def type
      RDF::Vocab::SCHEMA.EntryPoint
    end

    def http_method
      object.http_method.upcase
    end
  end
end
