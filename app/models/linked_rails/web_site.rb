# frozen_string_literal: true

module LinkedRails
  class WebSite < CreativeWork
    attr_accessor :homepage, :image, :navigations_menu

    class << self
      def iri
        RDF::Vocab::SCHEMA.WebSite
      end

      def show_includes
        super + [homepage: LinkedRails::WebPage.show_includes]
      end
    end
  end
end
