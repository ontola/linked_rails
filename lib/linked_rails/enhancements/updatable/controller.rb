# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Controller
        extend ActiveSupport::Concern

        included do
          active_response :update
        end
      end
    end
  end
end
