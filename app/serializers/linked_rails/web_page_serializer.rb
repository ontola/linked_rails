# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < ActiveModel::Serializer
    include LinkedRails::Serializer

    has_one :widget_sequence, predicate: LinkedRails::NS::ONTOLA[:widgets]
  end
end
