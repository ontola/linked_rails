# frozen_string_literal: true

class RecordSerializer
  include RDF::Serializers::ObjectSerializer
  include LinkedRails::Serializer

  attribute :title, predicate: Vocab.schema.name
  attribute :body, predicate: Vocab.schema.text
  attribute :key, predicate: LinkedRails.app_ns[:key]
  attribute :key1, predicate: LinkedRails.app_ns[:key1]
  attribute :key2, predicate: LinkedRails.app_ns[:key2]
  attribute :key3, predicate: LinkedRails.app_ns[:key3]
end
