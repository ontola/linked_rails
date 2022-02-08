# frozen_string_literal: true

module LinkedRails
  class EnumValueSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :label, predicate: Vocab.schema.name
    attribute :close_match, predicate: Vocab.skos.closeMatch
    attribute :exact_match, predicate: Vocab.skos.exactMatch
    attribute :group_by, predicate: Vocab.ontola[:groupBy]
    attribute :identifier, predicate: Vocab.schema.identifier
  end
end
