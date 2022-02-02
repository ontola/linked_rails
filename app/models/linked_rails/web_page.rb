# frozen_string_literal: true

module LinkedRails
  class WebPage < CreativeWork
    attr_writer :widgets
    attr_accessor :cover_photo, :includes, :hide_header

    def widget_sequence
      @widget_sequence ||= LinkedRails::Sequence.new(@widgets, parent: self, scope: false) if @widgets
    end

    class << self
      def iri
        Vocab.schema.WebPage
      end
    end
  end
end
