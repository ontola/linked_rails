# frozen_string_literal: true

module LinkedRails
  module Menus
    class ListSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      has_many :menus, predicate: Vocab::ONTOLA[:menus]
    end
  end
end
