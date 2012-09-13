#each of these calls from rake e.g. heroku run rake update_feed
# desc "This task is called by the Heroku scheduler add-on"
# task :update_feed => :environment do
#     puts "Updating feed..."
#     NewsFeed.update
#     puts "done."
# end

task :check_tip_deadlines => :environment do
    Event.check_tip_deadlines
end

task :backup_database => :environment do
	rake "pg_dump -a calenshare_production"
		# old_events = Event.where('events.start_time <= :one_week_ago', one_week_ago: Time.now - 1.week)
	# old_events.each do |oe|
	# 	oe.clean_up
	# end
end

#Should currently be accomplished with a worker through jobs:work => gcm:work
# task :send_gcm_notifications => :environment do

#To clear cache each week, from railscast on cron jobs
# every :friday, :at => "4am" do
# 	command "rm -rf #{RAILS_ROOT}/tmp/cache" #clear cache every friday
#   Event.clean_up
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