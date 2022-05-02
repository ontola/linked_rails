# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Sequence
      def add_sequence_to_slice(slice, serialization_params, **options)
        resource = options.delete(:resource)
        serializer = options[:serializer_class] || RDF::Serializers.serializer_for(resource)

        rid = create_record(slice, resource)

        add_attributes_to_record(serializer, slice, resource, rid, serialization_params)
        process_sequence_members(serializer, slice, resource, rid, serialization_params)
      end

      def process_sequence_members(serializer, slice, resource, rid, serialization_params, **options)
        index_predicate = serializer.relationships_to_serialize[:members].predicate
        nested = []
        resource.members.each_with_index.map do |m, i|
          symbol = uri_to_symbol(index_predicate.call(self, i))
          slice[rid][symbol] = value_to_emp_value(m)
          collect_nested_resources(nested, slice, resource, m, serialization_params)
        end
        nested.each do |r|
          resource_to_emp_json(slice, serialization_params, resource: r, includes: options[:includes])
        end
      end
    end
  end
end
