# frozen_string_literal: true

module LinkedRails
  module Helpers
    module DeltaHelper
      def changed_relations_triples # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        current_resource.previously_changed_relations.flat_map do |key, value|
          relation_iri = current_resource.send(key).iri
          predicate = value.options[:predicate]
          if key.to_s.ends_with?('_collection')
            [[Vocab::SP[:Variable], Vocab::ONTOLA[:baseCollection], relation_iri, delta_iri(:invalidate)]]
          elsif current_resource.send(:association_has_destructed?, key)
            [
              predicate ? [current_resource.iri, predicate, relation_iri, delta_iri(:remove)] : nil,
              [relation_iri, Vocab::SP[:Variable], Vocab::SP[:Variable], delta_iri(:invalidate)]
            ].compact
          else
            [
              predicate ? [current_resource.iri, predicate, relation_iri, delta_iri(:replace)] : nil,
              [relation_iri, Vocab::SP[:Variable], Vocab::SP[:Variable], delta_iri(:invalidate)]
            ].compact
          end
        end
      end

      def change_triple(predicate, value)
        if value.nil?
          RDF::Statement.new(current_resource.iri, predicate, Vocab::SP[:Variable], graph_name: delta_iri(:remove))
        else
          RDF::Statement.new(current_resource.iri, predicate, value, graph_name: delta_iri(:replace))
        end
      end

      def changes_triples # rubocop:disable Metrics/AbcSize
        serializer = ActiveModelSerializers::SerializableResource.new(current_resource, {}).serializer_instance
        current_resource.previous_changes_by_predicate.map do |predicate, (_old_value, _new_value)|
          serializer_attributes = current_resource.class.predicate_mapping[predicate]
          next if serializer_attributes.is_a?(ActiveModel::Serializer::Reflection)

          attr_name = serializer_attributes.name
          serialized_value = serializer.read_attribute_for_serialization(attr_name)
          (serialized_value.is_a?(Array) ? serialized_value : [serialized_value]).map do |value|
            change_triple(predicate, value)
          end
        end.compact.flatten
      end

      def delta_iri(delta)
        %i[remove replace invalidate].include?(delta) ? Vocab::ONTOLA[delta] : Vocab::LL[delta]
      end

      def invalidate_collection_delta(collection)
        [Vocab::SP[:Variable], Vocab::ONTOLA[:baseCollection], collection.iri, delta_iri(:invalidate)]
      end

      def invalidate_parent_collections_delta(resource)
        resource&.parent_collections(try(:user_context))&.map(&method(:invalidate_collection_delta)) || []
      end

      def invalidate_resource_delta(resource)
        [resource.iri, Vocab::SP[:Variable], Vocab::SP[:Variable], delta_iri(:invalidate)]
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
