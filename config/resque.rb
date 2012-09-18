#timeout 30         # restarts workers that hang for 30 seconds
4 after_fork do |server, worker|
5   defined?(ActiveRecord::Base) and
6   ActiveRecord::Base.establish_connection
7 end