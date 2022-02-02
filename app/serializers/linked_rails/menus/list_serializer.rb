# frozen_string_literal: true

module LinkedRails
  module Menus
    class ListSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      has_many :menus, predicate: Vocab.ontola[:menus] do |object|
        object.menus&.compact
      end
    end
  end
end
