# frozen_string_literal: true

module LinkedRails
  class FormSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    has_many :pages, predicate: Vocab.form[:pages], sequence: true, serializer: Form::PageSerializer
  end
end
