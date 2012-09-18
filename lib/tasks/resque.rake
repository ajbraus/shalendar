require 'resque/tasks'
 
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
 
task "apn:setup" => :environment do
  ENV['QUEUE'] = '*'
end

# desc "Alias for resque:work (To run workers on Heroku)"
# task "jobs:work" => "resque:work"

desc "Alias for apn:work (To run workers on Heroku)"
task "jobs:work" => "apn:work"

# desc "Alias for gcm:work"
# task "jobs:work" => "gcm:work"

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"