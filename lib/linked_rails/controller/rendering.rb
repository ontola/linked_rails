# frozen_string_literal: true

module LinkedRails
  module Controller
    module Rendering
      def _render_with_renderer_json(record, options)
        self.content_type = Mime[:json]

        return record if record.is_a?(String)
        return record.to_json if record.is_a?(Hash)

        serializer_opts = RDF::Serializers::Renderers.transform_opts(
          options,
          serializer_params
        )

        serializer = RDF::Serializers.serializer_for(record)&.new(record, serializer_opts)
        return record.to_json unless serializer

        Oj.dump(serializer.serializable_hash, mode: :compat)
      end

      def resource_body(resource)
        resource_serializer(resource).send(:render_emp_json)
      end

      def resource_hash(resource)
        resource_serializer(resource).send(:emp_json_hash)
      end

      def resource_serializer(resource)
        return if resource.nil?

        serializer_options = RDF::Serializers::Renderers.transform_opts(
          {include: resource&.try(:preview_includes)},
          serializer_params
        )
        RDF::Serializers
          .serializer_for(resource)
          &.new(resource, serializer_options)
      end

      def serializer_params
        {}
      end
    end
  end
end
