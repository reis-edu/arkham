# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Arkham
  class ArkhamSettings < Settingslogic
    source 'config/arkham.yml'
    namespace Rails.env
    suppress_errors true
  end

  def self.config
    ArkhamSettings
  end

  def self.logger
    Rails.logger
  end

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.eager_load_paths += %W[#{config.root}/lib #{config.root}/lib/arkham #{config.root}/lib/validation]
    config.action_controller.allow_forgery_protection = false

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post put delete patch options]
      end
    end

    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = :local

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
