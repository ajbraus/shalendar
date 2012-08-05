require 'development_mail_interceptor'

ActionMailer::Base.raise_delivery_errors = Rails.env.production? ? false : true
ActionMailer::Base.perform_deliveries = Rails.env.test? ? false : true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address        =>  "smtp.gmail.com",
    :port           =>  587,
    :domain         =>  "gmail.com",
    :user_name      =>  "calenshare@gmail.com",
    :password       =>  "calenshare1@#",
    :authentication =>  "plain",
    :enable_starttls_auto => true
  }

ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?