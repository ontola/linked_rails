# frozen_string_literal: true

module LinkedRails
  module Menus
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      has_one :action, predicate: Vocab::ONTOLA[:action]
      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :href, predicate: Vocab::ONTOLA[:href]

      has_one :image, predicate: RDF::Vocab::SCHEMA.image
      has_one :menu_sequence, predicate: Vocab::ONTOLA[:menuItems], if: :menus_present?
      has_one :parent, predicate: Vocab::ONTOLA[:parentMenu], if: :parent_menu?
      has_one :resource, predicate: RDF::Vocab::SCHEMA.isPartOf

      def parent_menu?
        object.parent.is_a?(LinkedRails.menus_item_class)
      end

      def action
        if object.action.is_a?(LinkedRails.actions_item_class)
          object.action
        else
          {id: object.action}
        end
      end

      def image
        serialize_image(object.image)
      end

      def menus_present?
        object.menu_sequence.present?
      end

      def type
        object.type || Vocab::ONTOLA[:MenuItem]
      end
    end
  end
end
