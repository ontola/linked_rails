# frozen_string_literal: true

module LinkedRails
  class EntryPointSerializer < ActiveModel::Serializer
    include LinkedRails::Serializer

    attribute :label, predicate: NS::SCHEMA[:name]
    attribute :description, predicate: NS::SCHEMA[:text]
    attribute :url, predicate: NS::SCHEMA[:url]
    attribute :http_method, key: :method, predicate: NS::SCHEMA[:httpMethod]
    attribute :image, predicate: NS::SCHEMA[:image]

    has_one :action_body, predicate: NS::LL[:actionBody]

    def type
      NS::SCHEMA[:EntryPoint]
    end

    def http_method
      object.http_method.upcase
    end
  end
end
