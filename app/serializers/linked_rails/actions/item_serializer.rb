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

      has_one :parent, predicate: NS::SCHEMA[:isPartOf]
      has_one :resource, predicate: NS::SCHEMA[:object]
      has_one :target, predicate: NS::SCHEMA[:target]

      delegate :type, to: :object

      def result
        object.result&.iri
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
