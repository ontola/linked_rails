# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < CreativeWorkSerializer
    has_one :cover_photo, predicate: Vocab.ontola[:coverPhoto], polymorphic: true
    has_one :widget_sequence, predicate: Vocab.ontola[:widgets], polymorphic: true
    has_many :includes, polymorphic: true
    attribute :hide_header, predicate: Vocab.ontola[:hideHeader]
  end
end
