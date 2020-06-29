# frozen_string_literal: true

module LinkedRails
  class Form
    class GroupSerializer < LinkedRails.serializer_parent_class
      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :description, predicate: RDF::Vocab::SCHEMA.text
      attribute :collapsible, predicate: Vocab::FORM[:collapsible]
      attribute :hidden, predicate: Vocab::FORM[:hidden]

      has_many :fields, predicate: Vocab::FORM[:fields], sequence: true
    end
  end
end
