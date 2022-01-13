# frozen_string_literal: true

module LinkedRails
  class Railtie < Rails::Railtie
    initializer :add_welcome_page do
      ActiveSupport.on_load(:action_controller_base) do
        require_relative '../rails/welcome_controller'
      end
    end
  end
end
