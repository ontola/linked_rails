# frozen_string_literal: true

module LinkedRails
  class WebSiteSerializer < CreativeWorkSerializer
    has_one :homepage, predicate: NS::FOAF[:homepage]
    has_one :image, predicate: NS::SCHEMA[:image]
    attribute :navigations_menu, predicate: LinkedRails::NS::ONTOLA[:navigationsMenu]

    def image
      serialize_image(object.image)
    end
  end
end
