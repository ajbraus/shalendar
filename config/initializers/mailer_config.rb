require 'development_mail_interceptor'

email_settings = YAML::load(File.open("#{Rails.root.to_s}/config/email.yml"))
ActionMailer::Base.raise_delivery_errors = Rails.env.production? ? false : true
ActionMailer::Base.perform_deliveries = Rails.env.test? ? false : true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?

ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?