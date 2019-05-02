# frozen_string_literal: true

module LinkedRails
  module Menus
    class ListSerializer < ActiveModel::Serializer
      include LinkedRails::Serializer

      has_many :menus, predicate: LinkedRails::NS::ONTOLA[:menus]
    end
  end
end
