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
<<<<<<< HEAD
=======
    account_uri ''
    bank_account_uri ''
    credits_uri ''
    credit_card_uri ''
    debits_uri ''
>>>>>>> new-interface
	end

  factory :venue do
    name 'Venue Test'
    email 'Venue@test.com'
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
    account_uri ''
    bank_account_uri ''
    credits_uri ''
    credit_card_uri ''
    debits_uri ''
  end

  factory :event do
    user_id ''
    parent_id ''
    starts_at ''
    duration '2'
    ends_at ''
    title 'Test Event'
    min '1'
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
<<<<<<< HEAD
    is_public ''
	end

  factory :rsvp do  
    plan_id ''
    guest_id ''
  end

=======
    city_id '2'
    is_public ''
	end

>>>>>>> new-interface
end