# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < CreativeWorkSerializer
    has_one :cover_photo, predicate: Vocab.ontola[:coverPhoto]
    has_one :widget_sequence, predicate: Vocab.ontola[:widgets]
    has_many :includes
    attribute :hide_header, predicate: Vocab.ontola[:hideHeader]
  end
end
