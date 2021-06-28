# frozen_string_literal: true

module LinkedRails
  class RDFErrorSerializer < LinkedRails.serializer_parent_class
    attribute :title, predicate: Vocab.schema.name
    attribute :message, predicate: Vocab.schema.text
  end
end
