#timeout 30         # restarts workers that hang for 30 seconds
after_fork do |server, worker, resque|
	logger.info("Got to after_fork in resque.rb config file")
  defined?(ActiveRecord::Base) and
	ActiveRecord::Base.establish_connection
end

