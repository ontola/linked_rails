# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Base
      def resource_to_emp_json(slice, serialization_params, **options)
        return if options[:resource].blank? || record_id(options[:resource])&.is_a?(Proc)

        return add_sequence_to_slice(slice, serialization_params, **options) if options[:resource].is_a?(LinkedRails::Sequence)
        return add_rdf_list_to_slice(slice, **options) if options[:resource].is_a?(RDF::List)
        raise('Trying to serialize mixed resources') if options[:serializer_class] == RDF::Serializers::ListSerializer

        add_record_to_slice(
          slice,
          serialization_params,
          **options
        )
      end
    end
  end
end
