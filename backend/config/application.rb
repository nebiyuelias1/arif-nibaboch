require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BackendWithContainer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Custom application configuration (config.x)
    # This centralizes the domain and protocol so they can be managed via environment
    # variables. Used by Action Mailer for generating absolute URLs in emails.
    config.x.domain = ENV["APP_DOMAIN"].presence || "localhost:3000"
    config.x.protocol = ENV["APP_PROTOCOL"].presence || "http"
    config.x.app_name = ENV["APP_NAME"].presence || "litloop"
    # The domain used for the 'from' address in emails. Default to the domain without port.
    config.x.mail_from_domain = ENV["APP_MAIL_FROM_DOMAIN"].presence || config.x.domain.split(":").first
    config.i18n.available_locales = [ :en, :am, :"zh-CN", :"zh-TW" ]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
  end
end
