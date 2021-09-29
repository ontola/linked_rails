# frozen_string_literal: true

module LinkedRails
  module Helpers
    module DeltaHelper
      def changed_relation_triples(predicate, destructed, resources)
        related_resource_invalidations = resources.map(&method(:invalidate_resource_delta))

        return related_resource_invalidations unless predicate

        if destructed
          return related_resource_invalidations + [
            [current_resource.iri, predicate, Vocab.sp[:Variable], delta_iri(:remove)]
          ]
        end

        related_resource_invalidations + resources.map do |resource|
          [current_resource.iri, predicate, resource.iri, delta_iri(:replace)]
        end
      end

      def changed_relations_triples # rubocop:disable Metrics/AbcSize
        current_resource.previously_changed_relations.flat_map do |key, value|
          if key.to_s.ends_with?('_collection')
            [invalidate_collection_delta(current_resource.send(key))]
          else
            destructed = current_resource.send(:association_has_destructed?, key)
            many = value.relationship_type == :has_many
            relation = current_resource.send(key)
            changed_relation_triples(value.predicate, destructed, many ? relation : [relation])
          end
        end
      end

      def change_triple(predicate, value)
        if value.nil?
          RDF::Statement.new(current_resource.iri, predicate, Vocab.sp[:Variable], graph_name: delta_iri(:remove))
        else
          RDF::Statement.new(current_resource.iri, predicate, value, graph_name: delta_iri(:replace))
        end
      end

      def changes_triples # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        serializer_class = RDF::Serializers.serializer_for(current_resource)
        return [] if serializer_class.blank?

        serializer = serializer_class.new(current_resource)

        current_resource.previous_changes_by_predicate.map do |predicate, (_old_value, _new_value)|
          serializer_attributes = current_resource.class.predicate_mapping[predicate]
          next if serializer_attributes.is_a?(FastJsonapi::Relationship)

          attr_name = serializer_attributes.key
          serialized_value =
            serializer.class.attributes_to_serialize[attr_name]&.serialize(current_resource, serializer_params, {})
          (serialized_value.is_a?(Array) ? serialized_value : [serialized_value]).map do |value|
            change_triple(predicate, value)
          end
        end.compact.flatten
      end

      def delta_iri(delta)
        %i[remove replace invalidate].include?(delta) ? Vocab.ontola[delta] : Vocab.ll[delta]
      end

      def invalidate_collection_delta(collection)
        [collection.iri, Vocab.ontola[:lastActivityAt], Time.current, delta_iri(:replace)]
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
