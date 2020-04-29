# frozen_string_literal: true

module LinkedRails
  class WebSiteSerializer < CreativeWorkSerializer
    has_one :homepage, predicate: RDF::Vocab::FOAF[:homepage], polymorphic: true
    attribute :image, predicate: RDF::Vocab::SCHEMA.image do |object|
      serialize_image(object.image)
    end
    attribute :navigations_menu, predicate: Vocab::ONTOLA[:navigationsMenu]
  end
end
