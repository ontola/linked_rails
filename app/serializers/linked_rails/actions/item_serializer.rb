# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: RDF::Vocab::SCHEMA.name
      attribute :description, predicate: RDF::Vocab::SCHEMA.text
      attribute :result, predicate: RDF::Vocab::SCHEMA.result
      attribute :action_status, predicate: RDF::Vocab::SCHEMA.actionStatus
      attribute :favorite, predicate: Vocab::ONTOLA[:favoriteAction]
      attribute :url, predicate: RDF::Vocab::SCHEMA.url

      has_one :parent, predicate: RDF::Vocab::SCHEMA.isPartOf
      has_one :resource, predicate: RDF::Vocab::SCHEMA.object
      has_one :target, predicate: RDF::Vocab::SCHEMA.target
      has_one :included_resource

      delegate :type, to: :object

      def result
        object.result&.iri
      end

      def url
        object.target[:id] if object.target.is_a?(Hash)
      end
    end
  end
end
