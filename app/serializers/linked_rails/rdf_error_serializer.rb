# frozen_string_literal: true

module LinkedRails
  class RDFErrorSerializer < LinkedRails.serializer_parent_class
    attribute :title, predicate: NS::SCHEMA.name
    attribute :message, predicate: NS::SCHEMA.text
  end
end
