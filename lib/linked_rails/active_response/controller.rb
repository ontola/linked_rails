# frozen_string_literal: true

require 'pundit'

require_relative 'controller/collections'
require_relative 'controller/crud_defaults'
require_relative 'controller/params'

module LinkedRails
  module Controller
    include Pundit
    include LinkedRails::ActiveResponse::Controller::Collections
    include LinkedRails::ActiveResponse::Controller::CrudDefaults
    include LinkedRails::ActiveResponse::Controller::Params

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

    def serializer_params
      {}
    end

    def success_message_translation_key
      "actions.#{Translate.translation_key(controller_class)}.#{action_name}.success"
    end

    def success_message_translation_opts
      {
        default: [:"actions.default.#{action_name}.success", ''],
        type: I18n.t("#{controller_class.model_name.collection}.type").capitalize
      }
    end
  end
end
