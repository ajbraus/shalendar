# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#eventually move this stuff into cron_controller
every 1.day do
	Notifier.digest.deliver
end

every 15.minutes do #we should start this off the 15-min increment so there's never overlap

	#events where the start time is between 1hr45mins and 2hrs from now
	window_floor = Time.now + 1.hour + 45.minutes
	window_ceiling = Time.now + 2.hours
	relevant_events = Event.where(':window_floor <= events.start_time AND 
												events.start_time < :window_ceiling',
												window_floor: window_floor, window_ceiling: window_ceiling)
	relevant_events.each do |re|

		if re.tipped?
			Notifier.reminder(re).deliver
		else
			Notifier.cancellation(re).deliver
			re.destroy
		end

	end

end

every 1.week do

	#output user/follower info for social graph info
	# User.all.each do |u|
	# 	??
	# end

	old_events = Event.where('events.start_time <= :one_week_ago', one_week_ago: Time.now - 1.week)
	old_events.each do |oe|
		#output event information for easy searching
		#oe.log
		oe.destroy
	end

end
#To clear cache each week, from railscast on cron jobs
# every :friday, :at => "4am" do
# 	command "rm -rf #{RAILS_ROOT}/tmp/cache" #clear cache every friday

end