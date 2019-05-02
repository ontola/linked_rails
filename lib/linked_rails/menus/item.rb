# frozen_string_literal: true

module LinkedRails
  module Menus
    class Item
      include ActiveModel::Model
      include ActiveModel::Serialization
      include LinkedRails::Model

      attr_accessor :parent, :tag, :item_type, :type, :resource
      attr_writer :action, :href, :image, :label, :menus

      %i[action href image label menus].each do |method|
        define_method method do
          value = instance_variable_get("@#{method}")
          value = instance_variable_set("@#{method}", parent.instance_exec(&value)) if value.respond_to?(:call)
          value
        end
      end

      def iri_path(fragment: nil) # rubocop:disable Metrics/MethodLength
        fragment = "##{fragment}" if fragment
        seperator =
          if parent.is_a?(List)
            '/'
          elsif parent.iri.to_s.include?('#')
            '.'
          else
            fragment = nil
            '#'
          end
        "#{parent.iri_path}#{seperator}#{tag}#{fragment}"
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

      class << self
        def preview_includes
          [:image, action: :target]
        end
      end
    end
  end
end
