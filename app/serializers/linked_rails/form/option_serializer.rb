# frozen_string_literal: true

module LinkedRails
  class Form
    class OptionSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: RDF::Vocab::SCHEMA.name
    end
  end
end
