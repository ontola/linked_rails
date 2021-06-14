# frozen_string_literal: true

module LinkedRails
  class WebSite < CreativeWork
    attr_accessor :homepage, :image, :navigations_menu

    class << self
      def iri
        RDF::Vocab::SCHEMA.WebSite
      end

      def preview_includes
        super + [homepage: LinkedRails::WebPage.preview_includes]
      end
    end
  end
end
