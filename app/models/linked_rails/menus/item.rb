# frozen_string_literal: true

module LinkedRails
  module Menus
    class Item
      include ActiveModel::Model
      include LinkedRails::Model
      include LinkedRails::CallableVariable

      attr_accessor :parent, :tag, :item_type, :type, :resource
      attr_writer :action, :href, :image, :iri_base, :label, :menus
      delegate :iri_opts, to: :parent

      alias id iri
      %i[action href image label menus iri_base].each do |method|
        callable_variable(method, instance: :parent)
      end

      def iri_opts
        parent.iri_opts.merge(
          tag: route_tag,
          fragment: route_fragment
        )
      end

      def iri_template
        return parent.send(:iri_template) unless parent.is_a?(LinkedRails::Menus::List)

        return LinkedRails::URITemplate.new("#{iri_base}{/tag}{#fragment}") if iri_base

        iri_template_expand_path(parent.send(:iri_template), '{/tag}')
      end

      def menu_sequence
        return if @menus.nil?

        @menu_sequence ||=
          LinkedRails::Sequence.new(
            -> { menus&.compact&.each { |menu| menu.parent = self } },
            id: menu_sequence_iri,
            parent: self,
            scope: false
          )
      end

      def menu_sequence_iri
        return @menu_sequence_iri if @menu_sequence_iri

        sequence_iri = iri.dup
        sequence_iri.path ||= ''
        sequence_iri.path += '/menu_items'
        sequence_iri
      end

      def rdf_type
        type || Vocab.ontola[:MenuItem]
      end

      def route_fragment
        return if parent.is_a?(LinkedRails::Menus::List)

        [parent.route_fragment, tag].compact.join('.')
      end

      def route_tag
        parent.is_a?(LinkedRails::Menus::List) ? tag : parent.route_tag
      end

      class << self
        def base_includes
          [action: :target]
        end

        def preview_includes
          base_includes + [
            menu_sequence: [
              members: base_includes +
                [menu_sequence: [members: base_includes]]
            ]
          ]
        end

        def requested_index_resource(params, user_context)
          parent = parent_from_params(params, user_context)
          return if parent.blank?

          parent.menu_sequence
        end
      end
    end
  end
end
