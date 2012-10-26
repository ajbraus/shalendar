FactoryGirl.define do
	factory :user do
    sequence(:name)  { |n| "User Number #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"} 
		password 'please'
		password_confirmation 'please'
	end

	factory :event do
		user
	end

	factory :comment do
		creator 'Test User'
		content 'Ill be 10 min late'
	end
	
end