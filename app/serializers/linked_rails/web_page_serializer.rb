# frozen_string_literal: true

module LinkedRails
  class WebPageSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    attribute :description, predicate: LinkedRails::NS::SCHEMA[:description]
    attribute :name, predicate: LinkedRails::NS::SCHEMA[:name]

    has_one :widget_sequence, predicate: LinkedRails::NS::ONTOLA[:widgets]
  end
end
