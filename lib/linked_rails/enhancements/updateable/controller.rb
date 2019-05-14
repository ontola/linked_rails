# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updateable
      module Controller
        extend ActiveSupport::Concern

        included do
          active_response :update, :edit
        end
      end
    end
  end
end
