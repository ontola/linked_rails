# frozen_string_literal: true

module LinkedRails
  module Helpers
    module OntolaActionsHelper
      def add_exec_action_header(headers, action)
        headers['Exec-Action'] ||= ''
        headers['Exec-Action'] += "#{action}\n"
      end

      def ontola_copy_action(value)
        NS::ONTOLA["actions/copyToClipboard?#{{value: value}.to_param}"]
      end

      def ontola_dialog_action(resource, opener: nil)
        NS::ONTOLA["actions/dialog/alert?#{{resource: resource, opener: opener}.compact.to_param}"]
      end

      def ontola_redirect_action(location, reload: nil)
        NS::ONTOLA["actions/redirect?#{{location: location, reload: reload}.compact.to_param}"]
      end

      def ontola_snackbar_action(text)
        NS::ONTOLA["actions/snackbar?#{{text: text}.to_param}"]
      end
    end
  end
end
