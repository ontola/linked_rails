# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Creatable
      module Controller
        extend ActiveSupport::Concern

        included do
          has_collection_create_action
        end
      end
    end
  end
end
