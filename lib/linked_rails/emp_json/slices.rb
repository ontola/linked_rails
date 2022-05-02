# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Slices
      def render_emp_json
        Oj.fast_generate(emp_json_hash)
      end

      def emp_json_hash
        create_slice(@resource)
      end

      def create_slice(resources)
        slice = {}

        (resources.is_a?(Array) ? resources : [resources]).each do |resource|
          resource_to_emp_json(
            slice,
            @params,
            resource: resource,
            serializer_class: self.class,
            includes: @rdf_includes
          )
        end

        slice
      end
    end
  end
end
