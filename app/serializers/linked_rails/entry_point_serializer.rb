# frozen_string_literal: true

module LinkedRails
  class EntryPointSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :label, predicate: Vocab.schema.name
    attribute :description, predicate: Vocab.schema.text
    attribute :url, predicate: Vocab.schema.url
    attribute :http_method, key: :method, predicate: Vocab.schema.httpMethod do |object|
      object.http_method.upcase
    end

    has_one :parent, predicate: Vocab.schema.isPartOf, polymorphic: true
    attribute :action_body, predicate: Vocab.ll[:actionBody], polymorphic: true
    attribute :image, predicate: Vocab.schema.image do |object|
      serialize_image(object.image)
    end
  end
end
