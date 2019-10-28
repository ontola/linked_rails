# frozen_string_literal: true

module LinkedRails
  class WebSiteSerializer < CreativeWorkSerializer
    has_one :homepage, predicate: RDF::Vocab::FOAF[:homepage]
    has_one :image, predicate: RDF::Vocab::SCHEMA.image
    attribute :navigations_menu, predicate: Vocab::ONTOLA[:navigationsMenu]

    def image
      serialize_image(object.image)
    end
  end
end
