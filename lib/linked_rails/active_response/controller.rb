# frozen_string_literal: true

require 'pundit'

require_relative 'controller/actions/items'
require_relative 'controller/collections'
require_relative 'controller/crud_defaults'

module LinkedRails
  module Controller
    include Pundit
    include LinkedRails::ActiveResponse::Controller::Actions
    include LinkedRails::ActiveResponse::Controller::Collections
    include LinkedRails::ActiveResponse::Controller::CrudDefaults

    def _render_with_renderer_json(record, options)
      self.content_type = Mime[:json]

      return record if record.is_a?(String)
      return record.to_json if record.is_a?(Hash)

      serializer_opts = RDF::Serializers::Renderers.transform_opts(
        options,
        respond_to?(:serializer_params, true) ? serializer_params : {}
      )

      serializer = RDF::Serializers.serializer_for(record)&.new(record, serializer_opts)
      return record.to_json unless serializer

      Oj.dump(serializer.serializable_hash, mode: :compat)
    end
  end
end
