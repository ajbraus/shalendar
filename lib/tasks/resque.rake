require 'resque/tasks'
 
task "resque:setup" => :environment do
ENV['QUEUE'] = '*'
end
 
task "apn:setup" => :environment do
  ENV['QUEUE'] = '*'
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

desc "Alias for apn:work (To run workers on Heroku)"
task "jobs:work" => "apn:work"

desc "Alias for gcm:notifications:deliver"
task "jobs:work" => "rake gcm:notifications:deliver"
