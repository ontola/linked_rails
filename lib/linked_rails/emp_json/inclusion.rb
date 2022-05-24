# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Inclusion
      # Modifies the nested_resources parameter
      def collect_nested_resources(nested_resources, slice, resource, value, serialization_params)
        case value
        when LinkedRails::Sequence
          collect_sequence_and_members(nested_resources, slice, resource, value, serialization_params)
        when RDF::List
          nested_resources.push value unless value.subject == NS.rdfv.nil
        when Array
          collect_array_members(nested_resources, slice, resource, value, serialization_params)
        else
          nested_resources.push value if blank_value(value) || nested_resource?(resource, value)
        end
      end

      def collect_sequence_and_members(nested_resources, slice, resource, value, serialization_params)
        value.members.map { |m| collect_nested_resources(nested_resources, slice, resource, m, serialization_params) }
        add_sequence_to_slice(slice, serialization_params, resource: value) unless slice[value.iri.to_s]
      end

      def collect_array_members(nested_resources, slice, resource, value, serialization_params)
        value.each { |m| collect_nested_resources(nested_resources, slice, resource, m, serialization_params) }
      end

      def blank_value(value)
        value.try(:iri)&.is_a?(RDF::Node)
      end

      def nested_resource?(resource, value)
        value.try(:iri)&.to_s&.include?('#') &&
          !resource.iri.to_s.include?('#') &&
          value.iri.to_s.starts_with?(resource.iri.to_s)
      end

      def process_includes(slice, serialization_params, **options) # rubocop:disable Metrics/MethodLength
        includes = options.delete(:includes)
        resource = options.delete(:resource)

        includes.each do |prop, nested|
          value = resource.try(prop)
          next if value.blank?

          (value.is_a?(Array) || value.is_a?(ActiveRecord::Relation) ? value : [value]).each do |v|
            if slice_includes_record?(slice, v)
              process_includes(slice, serialization_params, resource: v, includes: nested) if nested
            else
              resource_to_emp_json(slice, serialization_params, resource: v, includes: nested, **options)
            end
          end
        end
      end
    end
  end
end
