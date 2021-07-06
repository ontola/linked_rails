# frozen_string_literal: true

module LinkedRails
  class WebSiteSerializer < CreativeWorkSerializer
    has_one :homepage, predicate: Vocab.foaf.homepage, polymorphic: true
    attribute :image, predicate: Vocab.schema.image do |object|
      serialize_image(object.image)
    end
    attribute :navigations_menu, predicate: Vocab.ontola[:navigationsMenu]
  end
end
