# frozen_string_literal: true

module LinkedRails
  module Controller
    module Delta
      include LinkedRails::Helpers::DeltaHelper

      def changes_triples(resource) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        resource_serializer(resource)&.send(:repository).statements

        # resource.previous_changes_by_predicate.map do |predicate, (_old_value, _new_value)|
        #   serializer_attributes = resource.class.predicate_mapping[predicate]
        #   next if serializer_attributes.is_a?(FastJsonapi::Relationship)
        #
        #   attr_name = serializer_attributes.key
        #   serialized_value =
        #     serializer.class.attributes_to_serialize[attr_name]&.serialize(resource, serializer_params, {})
        #   (serialized_value.is_a?(Array) ? serialized_value : [serialized_value]).map do |value|
        #     change_triple(resource, predicate, value)
        #   end
        # end.compact.flatten
      end

      def changed_relations_triples(resource, inverted = nil) # rubocop:disable Metrics/AbcSize
        resource.previously_changed_relations.flat_map do |key, value|
          if key.to_s.ends_with?('_collection')
            changed_collection_triples(resource, key)
          else
            destructed = resource.send(:association_has_destructed?, key)
            records = value.relationship_type == :has_many ? resource.send(key) : [resource.send(key)]
            changed_relation_triples(value.predicate, destructed, records - [inverted], resource)
          end
        end
      end

      private

      def change_triple(resource, predicate, value)
        if value.nil?
          RDF::Statement.new(resource.iri, predicate, Vocab.sp[:Variable], graph_name: delta_iri(:remove))
        else
          RDF::Statement.new(resource.iri, predicate, value, graph_name: delta_iri(:replace))
        end
      end

      def changed_relation_triples(predicate, destructed, resources, inverted)
        related_resource_invalidations =
          resources.flat_map do |resource|
            resource_delta = invalidate_resource_delta(resource)
            [resource_delta] + changed_relations_triples(resource, inverted)
          end

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

      def changed_collection_triples(resource, key)
        collection = resource.send(key)
        association = resource.association(collection.association)
        if association.loaded?
          [invalidate_collection_delta(collection)] +
            association.reader.select { |r| r.previous_changes.present? }.flat_map(&method(:changes_triples))
        else
          [invalidate_collection_delta(collection)]
        end
      end
    end
  end
end
