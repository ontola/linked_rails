# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require 'linked_rails'

require 'linked_rails/middleware/linked_data_params'

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    Rails.application.routes.default_url_options[:host] = 'http://example.com'

    config.middleware.use LinkedRails::Middleware::LinkedDataParams
  end
end
