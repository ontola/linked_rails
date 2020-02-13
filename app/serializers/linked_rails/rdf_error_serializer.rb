# frozen_string_literal: true

module LinkedRails
  class RDFErrorSerializer < LinkedRails.serializer_parent_class
    attribute :type, predicate: RDF[:type]
    attribute :title, predicate: NS::SCHEMA.name
    attribute :message, predicate: NS::SCHEMA.text

    def type
      object.type
    end
  end
end
