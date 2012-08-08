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

#here set the output path so it will log in right place
set :cron_log, "~/desktop/shalendar/log/cron_log.log"

# every :friday, :at => "4am" do
# 	command "rm -rf #{RAILS_ROOT}/tmp/cache"
# 	runner "Event.clean_up"
# end

# every 1.day, at: '2:22 am' do

# 	command "pg_dump -a calenshare_development"
# end

# every 1.day, :at => '2:00 pm' do
# 	runner "Notifier.digest.deliver"


# end


# every 15.minutes, at: [8, 23, 38, 53] do #we should start this off the 15-min increment so there's never overlap

# 	runner "Event.first.check_tip_deadlines"
# 	#events where the start time is between 1hr45mins and 2hrs from now

# end

# PRUNE THE DB
# every 1.week do

	#output user/follower info for social graph info
	# User.all.each do |u|
	# 	??
	# end

	# pg_dump
	# old_events = Event.where('events.start_time <= :one_week_ago', one_week_ago: Time.now - 1.week)
	# old_events.each do |oe|
	# 	oe.clean_up
	# end

# end
#To clear cache each week, from railscast on cron jobs
# every :friday, :at => "4am" do
# 	command "rm -rf #{RAILS_ROOT}/tmp/cache" #clear cache every friday
# end