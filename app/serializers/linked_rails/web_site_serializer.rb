# frozen_string_literal: true

module LinkedRails
  class WebSiteSerializer < CreativeWorkSerializer
    has_one :homepage, predicate: NS::FOAF[:homepage]
    attribute :navigations_menu, predicate: LinkedRails::NS::ONTOLA[:navigationsMenu]
  end
end
