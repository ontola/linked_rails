# frozen_string_literal: true

module LinkedRails
  module Menus
    class ListSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      has_many :menus, predicate: Vocab.ontola[:menus], polymorphic: true do |object|
        object.menus&.compact
      end
    end
  end
end
