# frozen_string_literal: true

require_relative 'default_actions/create'

module LinkedRails
  module Actions
    module DefaultActions
      extend ActiveSupport::Concern

      included do
        extend LinkedRails::Actions::DefaultActions::Create
        extend LinkedRails::Actions::DefaultActions::Destroy
        extend LinkedRails::Actions::DefaultActions::Update
      end
    end
  end
end
