# frozen_string_literal: true

module LinkedRails
  module Helpers
    module DeltaHelper
      def delta_iri(delta)
        %i[remove replace invalidate].include?(delta) ? Vocab.ontola[delta] : Vocab.ld[delta]
      end

      def invalidate_collection_delta(collection)
        iri = collection.is_a?(RDF::Resource) ? collection : collection.iri

        [Vocab.sp[:Variable], Vocab.ontola[:baseCollection], iri, delta_iri(:invalidate)]
      end

      def invalidate_parent_collections_delta(resource)
        context = user_context if respond_to?(:user_context, true)

        resource&.parent_collections(context)&.map(&method(:invalidate_collection_delta)) || []
      end

      def invalidate_resource_delta(resource)
        iri = resource.is_a?(RDF::Resource) ? resource : resource.iri

        [iri, Vocab.sp[:Variable], Vocab.sp[:Variable], delta_iri(:invalidate)]
      end

      def resource_added_delta(resource)
        invalidate_parent_collections_delta(resource) + singular_added_delta(resource)
      end

      def resource_removed_delta(resource)
        invalidate_parent_collections_delta(resource) + singular_removed_delta(resource)
      end

      def same_as_statement(from, to)
        [
          from,
          Vocab.owl.sameAs,
          to
        ]
      end

      def singular_added_delta(resource)
        return [] unless resource.try(:singular_resource?)

        [same_as_statement(resource.singular_iri, resource.iri)]
      end

      def singular_removed_delta(resource)
        return [] unless resource.try(:singular_resource?)

        [invalidate_resource_delta(resource.singular_iri)]
      end
    end
  end
end
