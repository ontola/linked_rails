# frozen_string_literal: true

module LinkedRails
  class FormSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    has_many :pages, predicate: Vocab::FORM[:pages], sequence: true
  end
end
