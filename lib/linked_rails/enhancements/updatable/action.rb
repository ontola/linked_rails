# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Action
        extend ActiveSupport::Concern

        included do
          has_resource_update_action
        end
      end
    end
  end
end
