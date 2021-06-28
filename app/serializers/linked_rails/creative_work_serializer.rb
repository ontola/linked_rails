# frozen_string_literal: true

module LinkedRails
  class CreativeWorkSerializer < LinkedRails.serializer_parent_class
    attribute :description, predicate: Vocab.schema.description
    attribute :name, predicate: Vocab.schema.name
    attribute :text, predicate: Vocab.schema.text
    attribute :url, predicate: Vocab.schema.url
  end
end
