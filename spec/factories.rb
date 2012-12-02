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
		city_id '2'
		post_to_fb_wall 'f'
		avatar nil
		vendor 'f'
		terms 't'
        background nil
	end

  factory :vendor do
    name 'Vendor Test'
    email 'Vendor@test.com'
    password 'please'
    password_confirmation 'please'
    remember_me 'f'
    time_zone "Central Time (US & Canada)"
    require_confirm_follow 'f'
    allow_contact 't'
    digest 't'
    notify_event_reminders 't'
    city_id '2'
    post_to_fb_wall 'f'
    avatar nil
    vendor 't'
    terms 't'
    background nil
  end

  factory :event do
    user_id ''
    parent_id ''
    starts_at ''
    duration '2'
    ends_at ''
    title 'Test Event'
    min ''
    max ''
    address ''
    latitude ''
    longitude ''
    chronic_starts_at ''
    chronic_ends_at ''
    link ''
    gmaps 'f'
    tipped 't'
    guests_can_invite_friends 't'
    price ''
    promo_img nil
    promo_url ''
    promo_vid ''
    short_url ''
    slug ''
    city_id '2'
	end
end