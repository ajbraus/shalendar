
namespace :gcm do
	task :work do
		desc "Send gcm notifications"
		system "rake gcm:nofications:deliver"
	end
end