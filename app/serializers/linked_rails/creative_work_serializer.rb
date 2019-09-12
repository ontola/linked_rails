# frozen_string_literal: true

module LinkedRails
  class CreativeWorkSerializer < LinkedRails.serializer_parent_class
    attribute :description, predicate: LinkedRails::NS::SCHEMA[:description]
    attribute :name, predicate: NS::SCHEMA[:name]
    attribute :text, predicate: NS::SCHEMA[:text]
    attribute :url, predicate: NS::SCHEMA[:url]
  end
end
