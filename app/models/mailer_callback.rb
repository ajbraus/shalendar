#require 'resque/plugins/resque_heroku_autoscaler'

class MailerCallback
	#extend Resque::Plugins::HerokuAutoscaler

  # resque queue name
  def self.queue
    :email_queue
  end

  # resque callback method
  def self.perform(mailer, email_type, *args)
  	#logger.info("Got to perform the mailer callback with mailer = #{mailer} and event #{args[0]} and guest #{args[1]} ")
    
    mailer.constantize.send(email_type, *args).deliver

	rescue => ex
	  Airbrake.notify(ex)
  end
end

#Notifier.time_change(@event, g).deliver

#Resque.enqueue(MailerCallback, "Notifier", :welcome_email, args)