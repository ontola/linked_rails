# frozen_string_literal: true

class RecordSerializer
  include RDF::Serializers::ObjectSerializer
  include LinkedRails::Serializer

  attribute :title, predicate: Vocab.schema.name
  attribute :body, predicate: Vocab.schema.text
  attribute :key, predicate: Vocab.app[:key]
  attribute :key1, predicate: Vocab.app[:key1]
  attribute :key2, predicate: Vocab.app[:key2]
  attribute :key3, predicate: Vocab.app[:key3]
end
