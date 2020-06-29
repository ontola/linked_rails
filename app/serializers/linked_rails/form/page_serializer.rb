# frozen_string_literal: true

module LinkedRails
  class Form
    class PageSerializer < LinkedRails.serializer_parent_class
      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :description, predicate: RDF::Vocab::SCHEMA.text

      has_many :groups, predicate: Vocab::FORM[:groups], sequence: true
      has_one :footer_group, predicate: Vocab::FORM[:footerGroup]
    end
  end
end
