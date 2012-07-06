FactoryGirl.define do
	factory :user do
		first_name 'User'
    sequence(:last_name)  { |n| "Number #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"} 
		password 'please'
		password_confirmation 'please'
	end

	factory :event do
		user
	end
end