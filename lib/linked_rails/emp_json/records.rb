# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Records
      def add_record_to_slice(slice, serialization_params, **options)
        resource = options.delete(:resource)
        serializer = options.delete(:serializer_class) || RDF::Serializers.serializer_for(resource)

        rid = create_record(slice, resource)

        nested = build_record(serializer, slice, resource, rid, serialization_params)

        nested
          .reject { |r| slice_includes_record?(slice, r) }
          .each { |r| resource_to_emp_json(slice, serialization_params, resource: r) }
        process_includes(slice, serialization_params, resource: resource, **options) if options[:includes]
      end

      def build_record(serializer, slice, resource, rid, serialization_params)
        nested = add_attributes_to_record(serializer, slice, resource, rid, serialization_params)
        nested += add_relations_to_record(serializer, slice, resource, rid, serialization_params)

        add_statements_to_slice(serializer, slice, resource, serialization_params)

        nested
      end

      def create_record(slice, resource)
        id = resource.is_a?(RDF::Resource) ? resource : record_id(resource)
        value = primitive_to_value(id)

        unless slice_includes_record?(slice, resource)
          slice[value[:v]] = {
            "_id": value
          }
        end

        return value[:v]
      end

      def record_id(resource)
        return resource.to_s if resource.is_a?(URI) || resource.is_a?(RDF::URI)

        resource.try(:iri) || resource.try(:subject) || resource.id
      end

      def slice_includes_record?(slice, resource)
        slice.key?(object_to_value(resource)[:v])
      end
    end
  end
end
