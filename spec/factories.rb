FactoryGirl.define do
  factory :city do
    name 'Madison, Wisconsin'
    timezone 'Central Time (US & Canada)'
  end

	factory :user do
    sequence(:name)  { |n| "Test #{n}" }
    sequence(:email) { |n| "test@#{n}.com"} 
		password 'please'
		password_confirmation 'please'
		remember_me 'f'
		allow_contact 't'
		digest 't'
		notify_event_reminders 't'
		city_id '2'
		post_to_fb_wall 'f'
		avatar nil
		vendor 'f'
		terms 't'
    background nil
    account_uri ''
    bank_account_uri ''
    credits_uri ''
    credit_card_uri ''
    debits_uri ''
	end

  factory :event do
    user_id ''
    parent_id ''
    city_id '2'
    starts_at ''
    duration '2'
    ends_at ''
    title 'Test Event'
    address ''
    latitude ''
    longitude ''
    chronic_starts_at ''
    link ''
    gmaps 'f'
    price ''
    promo_img nil
    promo_url ''
    promo_vid ''
    short_url ''
    slug ''
    one_time ''
    dead 'f'
    friends_only ''
    end
end