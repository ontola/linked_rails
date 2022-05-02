# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Fields
      def add_attribute_to_record(slice, rid, symbol, value)
        return if value.nil?

        emp_value = value_to_emp_value(value)
        current_value = slice[rid][symbol]
        if current_value.is_a?(Array)
          slice[rid][symbol] = [*current_value, *(emp_value.is_a?(Array) ? emp_value : [emp_value])]
        elsif current_value
          slice[rid][symbol] = [current_value, *(emp_value.is_a?(Array) ? emp_value : [emp_value])]
        else
          slice[rid][symbol] = emp_value
        end
      end

      # Modifies the record parameter
      def add_attributes_to_record(serializer, slice, resource, rid, serialization_params) # rubocop:disable Metrics/MethodLength
        return [] if serializer.attributes_to_serialize.blank?

        nested_resources = []
        serializer.attributes_to_serialize.each do |_, attr|
          next if attr.predicate.blank? || !attr.conditionally_allowed?(resource, serialization_params)

          value = value_for_attribute(attr, resource, serialization_params)
          symbol = predicate_to_symbol(attr)
          add_attribute_to_record(slice, rid, symbol, value)
          collect_nested_resources(nested_resources, slice, resource, value, serialization_params) if value.present?
        end

        nested_resources
      end

      # Modifies the slice parameter
      def add_statements_to_slice(serializer, slice, resource, serialization_params) # rubocop:disable Metrics/AbcSize
        serializer._statements&.each do |key|
          serializer.send(key, resource, serialization_params).each do |statement|
            subject, predicate, value = unpack_statement(statement)

            next if value.nil?

            symbol = uri_to_symbol(predicate)
            rid = create_record(slice, subject)
            add_attribute_to_record(slice, rid, symbol, value)
          end
        end
      end

      # Modifies the record parameter
      def add_relations_to_record(serializer, slice, resource, rid, serialization_params) # rubocop:disable Metrics/MethodLength
        return [] if serializer.relationships_to_serialize.blank?

        nested_resources = []
        serializer.relationships_to_serialize.each do |_, relationship|
          next unless relationship.include_relationship?(resource, serialization_params)

          value = value_for_relation(relationship, resource, serialization_params)
          next if value.nil?

          symbol = predicate_to_symbol(relationship)
          add_attribute_to_record(slice, rid, symbol, value)

          collect_nested_resources(nested_resources, slice, resource, value, serialization_params)
        end

        nested_resources
      end

      def value_for_attribute(attr, resource, serialization_params)
        return resource.try(attr.method) if attr.method.is_a?(Symbol)

        FastJsonapi.call_proc(attr.method, resource, serialization_params)
      end

      def value_for_relation(relation, resource, serialization_params)
        value = unpack_relation_value(relation, resource, serialization_params)

        return if value.nil?

        if relation.sequence
          wrap_relation_in_sequence(value, resource)
        else
          value
        end
      end

      def unpack_relation_value(relation, resource, serialization_params)
        if relation.object_block
          FastJsonapi.call_proc(relation.object_block, resource, serialization_params)
        else
          resource.try(relation.key)
        end
      end

      def wrap_relation_in_sequence(value, resource)
        LinkedRails::Sequence.new(
          value.is_a?(Array) ? value : [value],
          parent: resource,
          scope: false
        )
      end

      def unpack_statement(statement)
        subject = statement.try(:subject) || statement[0]
        predicate = statement.try(:predicate) || statement[1]
        value = statement.try(:object) || statement[2]

        [subject, predicate, value]
      end

      def uri_to_symbol(uri)
        casing = symbolize == :class ? :upper : :lower

        if symbolize
          (uri.fragment || uri.path.split('/').last).camelize(casing)
        else
          uri.to_s
        end
      end

      def predicate_to_symbol(attr)
        return uri_to_symbol(attr.predicate) if attr.predicate.present?

        attr.key
      end

      def value_to_emp_value(value) # rubocop:disable Metrics/MethodLength
        case value
        when ActiveRecord::Associations::CollectionProxy
          value.map { |iri| object_to_value(iri) }.compact
        when LinkedRails::Sequence
          object_to_value(value.iri)
        when RDF::List
          object_to_value(value.subject)
        when Array, ActiveRecord::Relation
          value.map { |v| object_to_value(v) }.compact
        else
          object_to_value(value)
        end
      end
    end
  end
end
