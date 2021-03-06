# frozen_string_literal: true

module LinkedRails
  class WebPage < CreativeWork
    attr_writer :widgets
    attr_accessor :cover_photo, :includes, :hide_header

    def widget_sequence
      @widget_sequence ||= LinkedRails::Sequence.new(@widgets) if @widgets
    end

    class << self
      def iri
        RDF::Vocab::SCHEMA.WebPage
      end

      def show_includes
        super + [:includes, widget_sequence: {members: LinkedRails::Widget.show_includes}]
      end
    end
  end
end
