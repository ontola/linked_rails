# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Controller
        extend ActiveSupport::Concern

        included do
          active_response :destroy
        end
      end
    end
  end
end
