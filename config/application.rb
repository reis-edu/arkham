# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Arkham
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.action_controller.allow_forgery_protection = false

    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = :local

    config.arkham_settings = config_for(:arkham)
  end

  def self.config
    Rails.application.config.arkham_settings
  end

  def self.logger
    Rails.logger
  end
end
