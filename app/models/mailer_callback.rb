#require 'resque/plugins/resque_heroku_autoscaler'

class MailerCallback
	#extend Resque::Plugins::HerokuAutoscaler

  # resque queue name
  def self.queue
    :email_queue
  end

  # resque callback method
  def self.perform(mailer, email_type, *args)
    mailer.constantize.send(email_type, args).deliver
  end
end

#Notifier.time_change(@event, g).deliver

#Resque.enqueue(MailerCallback, "Notifier", :welcome_email, args)