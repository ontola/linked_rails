# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Creatable
      module Controller
        extend ActiveSupport::Concern

        included do
          active_response :create
        end
      end
    end
  end
end
