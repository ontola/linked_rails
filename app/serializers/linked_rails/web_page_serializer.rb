# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < CreativeWorkSerializer
    has_one :cover_photo, predicate: Vocab::ONTOLA[:coverPhoto]
    has_one :widget_sequence, predicate: Vocab::ONTOLA[:widgets]
    has_many :includes
  end
end
