# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Controller
        extend ActiveSupport::Concern

        included do
          active_response :delete, :destroy
        end

        private

        def delete_success
          respond_with_form(delete_success_options)
        end

        def delete_success_options
          default_form_options(:delete)
        end
      end
    end
  end
end
