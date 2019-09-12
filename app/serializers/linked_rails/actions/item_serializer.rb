# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemSerializer < LinkedRails.serializer_parent_class
      include LinkedRails::Serializer

      attribute :label, predicate: NS::SCHEMA[:name]
      attribute :description, predicate: NS::SCHEMA[:text]
      attribute :result, predicate: NS::SCHEMA[:result]
      attribute :action_status, predicate: NS::SCHEMA[:actionStatus]
      attribute :favorite, predicate: LinkedRails::NS::ONTOLA[:favoriteAction]
      attribute :url, predicate: NS::SCHEMA[:url]

      has_one :parent, predicate: NS::SCHEMA[:isPartOf]
      has_one :resource, predicate: NS::SCHEMA[:object]
      has_one :target, predicate: NS::SCHEMA[:target]
      has_one :included_resource

      delegate :type, to: :object

      def result
        object.result&.iri
      end

      def url
        object.target[:id] if object.target.is_a?(Hash)
      end

      def parent
        if object.resource.is_a?(LinkedRails.collection_class)
          object.resource.parent
        else
          object.resource
        end
      end
    end
  end
end
