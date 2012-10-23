FactoryGirl.define do
	factory :user do
    sequence(:name)  { |n| "Test #{n}" }
    sequence(:email) { |n| "test@#{n}.com"} 
		password 'please'
		password_confirmation 'please'
		remember_me 'f'
		time_zone "Central Time (US & Canada)"
		require_confirm_follow 'f'
		allow_contact 't'
		digest 't'
		notify_event_reminders 't'
		city 'Madison, Wisconsin'
		post_to_fb_wall 'f'
		avatar nil
		vendor 'f'
		terms 't'
	end
end