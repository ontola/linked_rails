# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :description, predicate: RDF::Vocab::SCHEMA.text
      attribute :result, predicate: RDF::Vocab::SCHEMA.result do |object|
        object.result&.iri
      end
      attribute :action_status, predicate: RDF::Vocab::SCHEMA.actionStatus
      attribute :favorite, predicate: Vocab::ONTOLA[:favoriteAction]
      attribute :url, predicate: RDF::Vocab::SCHEMA.url do |object|
        object.target[:id] if object.target.is_a?(Hash)
      end
      attribute :error, predicate: RDF::Vocab::SCHEMA.error

      has_one :parent, predicate: RDF::Vocab::SCHEMA.isPartOf, polymorphic: true
      has_one :object, predicate: RDF::Vocab::SCHEMA.object, polymorphic: true
      has_one :target, predicate: RDF::Vocab::SCHEMA.target, polymorphic: true
      has_one :included_object, polymorphic: true
    end
  end
end
