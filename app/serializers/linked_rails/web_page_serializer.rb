# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < CreativeWorkSerializer
    has_one :cover_photo, predicate: LinkedRails::NS::ONTOLA[:coverPhoto]
    has_one :widget_sequence, predicate: LinkedRails::NS::ONTOLA[:widgets]
    has_many :includes
  end
end
