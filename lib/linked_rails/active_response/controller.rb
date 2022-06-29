# frozen_string_literal: true

require 'pundit'

require_relative 'controller/collections'
require_relative 'controller/crud_defaults'
require_relative 'controller/params'

module LinkedRails
  module Controller
    include Pundit::Authorization
    include LinkedRails::ActiveResponse::Controller::Collections
    include LinkedRails::ActiveResponse::Controller::CrudDefaults
    include LinkedRails::ActiveResponse::Controller::Params

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
