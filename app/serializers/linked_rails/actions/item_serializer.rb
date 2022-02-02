# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: Vocab.schema.name
      attribute :description, predicate: Vocab.schema.text
      attribute :result, predicate: Vocab.schema.result do |object|
        object.result&.iri
      end
      attribute :action_status, predicate: Vocab.schema.actionStatus
      attribute :favorite, predicate: Vocab.ontola[:favoriteAction]
      attribute :one_click, predicate: Vocab.ontola[:oneClick]
      attribute :target_url, predicate: Vocab.schema.url do |object|
        object.target[:id] if object.target.is_a?(Hash)
      end
      attribute :error, predicate: Vocab.schema.error

      has_one :parent, predicate: Vocab.schema.isPartOf do |object|
        object.parent unless object.parent.try(:anonymous_iri?)
      end
      attribute :object_iri, predicate: Vocab.schema.object
      has_one :target, predicate: Vocab.schema.target
    end
  end
end
