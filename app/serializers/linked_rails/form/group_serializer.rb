# frozen_string_literal: true

module LinkedRails
  class Form
    class GroupSerializer < LinkedRails.serializer_parent_class
      attribute :label, predicate: Vocab.schema.name
      attribute :description, predicate: Vocab.schema.text
      attribute :collapsible, predicate: Vocab.form[:collapsible]
      attribute :hidden, predicate: Vocab.form[:hidden]

      has_many :fields, predicate: Vocab.form[:fields], sequence: true, polymorphic: true
    end
  end
end
