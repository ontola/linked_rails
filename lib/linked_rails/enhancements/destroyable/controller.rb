# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Controller
        extend ActiveSupport::Concern

        included do
          has_resource_destroy_action
        end
      end
    end
  end
end
