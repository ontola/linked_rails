# frozen_string_literal: true

class RecordSerializer
  include RDF::Serializers::ObjectSerializer
  include LinkedRails::Serializer

  attribute :title, predicate: RDF::Vocab::SCHEMA.name
  attribute :body, predicate: RDF::Vocab::SCHEMA.text
end
