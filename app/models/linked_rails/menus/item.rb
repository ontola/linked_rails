# frozen_string_literal: true

module LinkedRails
  module Menus
    class Item
      include ActiveModel::Model
      include ActiveModel::Serialization
      include LinkedRails::Model
      include LinkedRails::CallableVariable

      attr_accessor :parent, :tag, :item_type, :type, :resource
      attr_writer :action, :href, :image, :iri_base, :iri_tag, :label, :menus

      %i[action href image iri_tag label menus].each do |method|
        callable_variable(method, instance: :parent)
      end
      callable_variable(:iri_base, instance: :parent, default: -> { parent.iri_path })

      def iri_path(fragment: nil) # rubocop:disable Metrics/MethodLength
        fragment = "##{fragment}" if fragment
        seperator =
          if parent.is_a?(LinkedRails::Menus::List)
            '/'
          elsif parent.iri.to_s.include?('#')
            '.'
          else
            fragment = nil
            '#'
          end
        "#{iri_base}#{seperator}#{tag}#{fragment}"
      end

      def menu_sequence
        return if menus.blank?

        @menu_sequence ||=
          LinkedRails::Sequence.new(
            -> { menus&.compact&.each { |menu| menu.parent = self } },
            id: menu_sequence_iri
          )
      end

      def menu_sequence_iri
        iri_from_path("#{iri_path}/menus")
      end

      private

      def iri_tag
        @iri_tag || tag
      end

      class << self
        def preview_includes
          [:image, action: :target]
        end
      end
    end
  end
end
