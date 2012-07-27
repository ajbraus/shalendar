Shalendar::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Enables serving of images, sytlesheets, and JavaScripts from an asset
  # config.action_controller.asset_host = "http://assets.example.com"
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Recaptcha 
  Recaptcha.configure do |config|
  config.public_key  = '6Lc4mNQSAAAAAGogl0qfZI3tvZcdSglWAGqIKflk' #calenshare.dev
  config.private_key = '6Lc4mNQSAAAAADMQWInE5gXqUrH6-jWPTY3tQerq'
  end


  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

end
