# frozen_string_literal: true

module LinkedRails
  module Menus
    class ItemSerializer < ActiveModel::Serializer
      include LinkedRails::Serializer

      has_one :action, predicate: LinkedRails::NS::ONTOLA[:action]
      attribute :label, predicate: NS::SCHEMA[:name]
      attribute :href, predicate: LinkedRails::NS::ONTOLA[:href]

      has_one :image, predicate: NS::SCHEMA[:image]
      has_one :menu_sequence, predicate: LinkedRails::NS::ONTOLA[:menuItems], if: :menus_present?
      has_one :parent, predicate: LinkedRails::NS::ONTOLA[:parentMenu], if: :parent_menu?
      has_one :resource, predicate: NS::SCHEMA[:isPartOf]

      def parent_menu?
        object.parent.is_a?(LinkedRails::Menus::Item)
      end

      def action
        if object.action.is_a?(LinkedRails::Actions::Item)
          object.action
        else
          {id: object.action}
        end
      end

      def menus_present?
        object.menu_sequence.present?
      end

      def type
        object.type || LinkedRails::NS::ONTOLA[:MenuItem]
      end
    end
  end
end
