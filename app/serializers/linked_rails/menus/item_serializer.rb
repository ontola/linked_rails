# frozen_string_literal: true

module LinkedRails
  module Menus
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :href, predicate: Vocab::ONTOLA[:href]
      attribute :action, predicate: Vocab::ONTOLA[:action] do |object|
        object.action if object.action.is_a?(RDF::Resource)
      end
      attribute :image, predicate: RDF::Vocab::SCHEMA.image do |object|
        serialize_image(object.image)
      end
      has_one :action, predicate: Vocab::ONTOLA[:action], polymorphic: true do |object|
        object.action unless object.action.is_a?(RDF::Resource)
      end
      has_one :menu_sequence,
              predicate: Vocab::ONTOLA[:menuItems],
              if: ->(o, p) { menus_present?(o, p) },
              polymorphic: true
      has_one :parent, predicate: Vocab::ONTOLA[:parentMenu], if: ->(o, p) { parent_menu?(o, p) }, polymorphic: true
      has_one :resource, predicate: RDF::Vocab::SCHEMA.isPartOf, polymorphic: true

      def self.parent_menu?(object, _params)
        object.parent.is_a?(LinkedRails.menus_item_class)
      end

      def self.menus_present?(object, _params)
        object.instance_variables.include?(:@menus)
      end
    end
  end
end
