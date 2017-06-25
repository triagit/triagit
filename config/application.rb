require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require "action_cable/engine"
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Triaggit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
    config.action_controller.include_all_helpers = false
    config.middleware.delete ::Rack::Sendfile
    config.middleware.delete ::Rack::ETag
    config.middleware.delete ::Rack::MethodOverride
    config.middleware.delete ::Rack::Runtime
    config.middleware.delete ::Rack::Head
    config.middleware.delete ::Rack::ConditionalGet
    config.middleware.delete ::ActionDispatch::RequestId
    config.middleware.delete ::ActionDispatch::Flash
  end
end
