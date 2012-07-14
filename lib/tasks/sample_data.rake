namespace :db do
  desc "Erase and fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
    #make_events
  end
end

def make_users
  60.times do |n|
    first_name  = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email = "example-#{n+1}@gmail.com"
    password  = "password"
    User.create!(first_name: first_name,
                 last_name: last_name,
                 email: email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end

# def make_events
#   users = User.all(limit: 5)
#   3.times do |n|
#     title = Faker::Name.title
#     description = Faker::Lorem.sentence(2)
#     starts_at = Time.now + (n+3).hours
#     ends_at = Time.now + (n+4).hours
#     location = Faker::Address.city
#     min = 2
#     max = 3

#     users.each { |user| user.events.create!(title: title, 
#                                             description: description,
#                                             starts_at: starts_at,
#                                             ends_at: ends_at,
#                                             location: location,
#                                             min: min,
#                                             max: max,
#                                             ) }
#   end
# end
