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

task :digest => :environment do
	User.digest
end

task :follow_up => :environment do
	User.follow_up
end

task :test_notifications => :environment do

	android_user = User.find(140)
	gcm_device = Gcm::Device.find(android_user.GCMdevice_id)
	n = Gcm::Notification.new
	n.device = gcm_device
	n.collapse_key = "test generated push"
	n.delay_while_idle = true
	n.data = {:registration_ids => [android_user.GCMtoken], :data => {:message_text => "Happy afternoon!"}}
	n.save

	iphone_user = User.find(3) #michael's iPhone
	ios_device = APN::Device.find_by_id(iphone_user.apn_device_id)
	n = APN::Notification.new
  n.device = ios_device
  n.alert = "Test Generated Push"
  n.badge = 5
  n.sound = true
  n.custom_properties = {:type => "test_push"}
  n.save

end

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
