require 'resque/tasks'
 
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  logger.info("getting to the resque setup!")
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
 	Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
 
task "apn:setup" => :environment do
  ENV['QUEUE'] = '*'
  logger.info("getting to the apn setup")
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

desc "Alias for apn:work (To run workers on Heroku)"
task "jobs:work" => "apn:work"

# desc "Alias for gcm:work"
# task "jobs:work" => "gcm:work"