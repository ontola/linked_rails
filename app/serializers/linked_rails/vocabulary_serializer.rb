# frozen_string_literal: true

module LinkedRails
  class VocabularySerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    statements :graph

    def self.graph(object, _params)
      object.graph
    end
  end
end
