# frozen_string_literal: true

module LinkedRails
  module Helpers
    module DeltaHelper
      def changed_relations_triples # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        current_resource.previously_changed_relations.flat_map do |key, value|
          relation_iri = current_resource.send(key).iri
          if key.to_s.ends_with?('_collection')
            [[NS::SP[:Variable], NS::ONTOLA[:baseCollection], relation_iri, NS::ONTOLA[:invalidate]]]
          elsif current_resource.send(:association_has_destructed?, key)
            [
              [current_resource.iri, value.options[:predicate], relation_iri, NS::ONTOLA[:remove]],
              [relation_iri, NS::SP[:Variable], NS::SP[:Variable], NS::ONTOLA[:invalidate]]
            ]
          else
            [
              [current_resource.iri, value.options[:predicate], relation_iri, NS::ONTOLA[:replace]],
              [relation_iri, NS::SP[:Variable], NS::SP[:Variable], NS::ONTOLA[:invalidate]]
            ]
          end
        end
      end

      def changes_triples # rubocop:disable Metrics/AbcSize
        serializer = ActiveModelSerializers::SerializableResource.new(current_resource, {}).serializer_instance
        current_resource.previous_changes_by_predicate.map do |predicate, (_old_value, _new_value)|
          attr_name = current_resource.class.predicate_mapping[predicate].name
          serialized_value = serializer.read_attribute_for_serialization(attr_name)
          (serialized_value.is_a?(Array) ? serialized_value : [serialized_value]).map do |value|
            RDF::Statement.new(current_resource.iri, predicate, value, graph_name: NS::ONTOLA[:replace])
          end
        end.flatten
      end

      def delta_iri(delta)
        %i[remove replace invalidate].include?(delta) ? NS::ONTOLA[delta] : NS::LL[delta]
      end

      def invalidate_collection_delta(collection)
        [LinkedRails::NS::SP[:Variable], NS::ONTOLA[:baseCollection], collection.iri, NS::ONTOLA[:invalidate]]
      end

      def invalidate_parent_collections_delta(resource)
        resource.parent_collections(try(:user_context)).map(&method(:invalidate_collection_delta))
      end

      def invalidate_resource_delta(resource)
        [resource.iri, LinkedRails::NS::SP[:Variable], LinkedRails::NS::SP[:Variable], NS::ONTOLA[:invalidate]]
      end

      def resource_added_delta(resource)
        invalidate_parent_collections_delta(resource) + [invalidate_resource_delta(resource)]
      end

      def resource_removed_delta(resource)
        invalidate_parent_collections_delta(resource)
      end
    end
  end
end
