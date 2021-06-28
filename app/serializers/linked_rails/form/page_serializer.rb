# frozen_string_literal: true

module LinkedRails
  class Form
    class PageSerializer < LinkedRails.serializer_parent_class
      attribute :label, predicate: Vocab.schema.name
      attribute :description, predicate: Vocab.schema.text

      has_many :groups, predicate: Vocab.form[:groups], sequence: true
      has_one :footer_group, predicate: Vocab.form[:footerGroup]
    end
  end
end
