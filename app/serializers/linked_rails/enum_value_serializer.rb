# frozen_string_literal: true

module LinkedRails
  class EnumValueSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :label, predicate: RDF::Vocab::SCHEMA.name
    attribute :close_match, predicate: RDF::Vocab::SKOS.closeMatch
    attribute :exact_match, predicate: RDF::Vocab::SKOS.exactMatch
    attribute :group_by, predicate: Vocab::ONTOLA[:groupBy]
  end
end
