# frozen_string_literal: true

module LinkedRails
  class WebSite < CreativeWork
    attr_accessor :homepage, :image, :navigations_menu

    class << self
      def iri
        Vocab.schema.WebSite
      end
    end
  end
end
