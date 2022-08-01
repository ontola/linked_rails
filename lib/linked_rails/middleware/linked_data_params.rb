# frozen_string_literal: true

# require 'empathy/emp_json'

module LinkedRails
  module Middleware
    class LinkedDataParams
      include ::Empathy::EmpJson::Helpers::Slices
      include ::Empathy::EmpJson::Helpers::Parsing

      def initialize(app)
        @app = app
      end

      def call(env)
        req = Rack::Request.new(env)
        params_from_query(req)
        params_from_slice(req)

        @app.call(env)
      end

      private

      def add_param_from_query(data, target_class, key, value)
        data[target_class.predicate_mapping[RDF::URI(key)].key] = value
      end

      def convert_query_params(request, target_class)
        keys = target_class.predicate_mapping.keys.map(&:to_s)
        class_key = target_class.to_s.underscore
        data = request.params[class_key] || {}
        request.params.slice(*keys.map(&:to_s)).each do |key, value|
          add_param_from_query(data, target_class, key, value)
        end
        request.update_param(class_key, data) if data.present?
      end

      def slice_from_request(request)
        return unless request.content_type == Mime::Type.lookup_by_extension(:empjson).to_s

        body = request.body.read

        JSON.parse(body) if body.present?
      end

      # Converts a emp slice from to a nested attributes hash.
      #
      # The entrypoint for the slice is the `.` subject, which is
      # assumed to be the resource intended to be targeted by the request (i.e. the
      # resource to be created, updated, or deleted).
      #
      # @return [Hash] A hash of attributes, empty if no statements were given.
      def params_from_slice(request)
        slice = slice_from_request(request)

        return unless slice

        request.env['emp_json'] = slice
        target_class = target_class_from_path(request)
        return if target_class.blank?

        update_actor_param(request, slice)
        update_target_params(request, slice, target_class)
      end

      def params_from_query(request)
        target_class = target_class_from_path(request) if request.params.present?
        return unless target_class.try(:predicate_mapping)

        convert_query_params(request, target_class)
      end

      def target_class_from_path(request) # rubocop:disable Metrics/AbcSize
        opts = LinkedRails.iri_mapper.opts_from_iri(
          request.base_url + request.env['REQUEST_URI'],
          method: request.request_method
        )

        Rails.logger.info("No class found for #{request.base_url + request.env['REQUEST_URI']}") unless opts[:class]

        opts[:class]
      end

      def update_actor_param(request, slice)
        actor = values_from_slice(slice, '.', Vocab.schema.creator)

        return if actor.blank?

        request.update_param(:actor_iri, emp_to_primitive(actor))
      end

      def update_target_params(request, slice, target_class)
        key = target_class.to_s.demodulize.underscore

        parser = ParamsParser.new(slice: slice, params: request.params)
        from_body = parser.parse_resource('.', target_class)

        request.update_param(key, from_body.merge(request.params[key] || {}))
      end
    end
  end
end
