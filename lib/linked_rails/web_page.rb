# frozen_string_literal: true

module LinkedRails
  class WebPage
    include ActiveModel::Model
    include ActiveModel::Serialization
    include LinkedRails::Model

    attr_writer :iri, :widgets

    def widget_sequence
      @widget_sequence ||= LinkedRails::Sequence.new(@widgets)
    end

    class << self
      def iri
        LinkedRails::NS::SCHEMA[:WebPage]
      end

      def show_includes
        super + [widget_sequence: {members: Widget.show_includes}]
      end
    end
  end
end
