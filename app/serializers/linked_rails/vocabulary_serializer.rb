# frozen_string_literal: true

module LinkedRails
  class VocabularySerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    statements :graph
  end
end
