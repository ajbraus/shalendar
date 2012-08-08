namespace :db do
  desc "Erase and fill database with sample data"
  task populate: :environment do
    make_users
    make_relationships
    make_events
  end
end

def make_users
  60.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@gmail.com"
    password  = "password"

    terms = true
    User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 terms: terms,
                 require_confirm_follow: false
                 )
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

def make_events
  users = User.all(limit: 7)
  rsvps1 = users[0..3]
  rsvps2 = users[4..6]
  5.times do |e|
    id = e
    title = "Fun Time #{e+1}"
    description = Faker::Lorem.sentences(1)
    starts_at = Time.now + (e).days - (e).hours
    ends_at = Time.now + (e).days - (e-2).hours
    min = 2
    max = 20
    @event = users[e].events.build(
                        id: id,
                        title: title,
                        description: description,
                        starts_at: starts_at,
                        ends_at: ends_at,
                        min: min,
                        max: max
                        )
    @event.save
    users[e+1].rsvp!(@event)
  end
end
#MORE COMPLICATED EVENT MAKING
  # users.each do |user|
  #   5.times do |e|
  #     id = e + user.id*10 + 1
  #     title = "Fun Time #{e+1}"
  #     description = Faker::Lorem.sentences(1)
  #     starts_at = Time.now + (e+user.id).days - (e+user.id).hours
  #     ends_at = Time.now + (e+user.id).days - (e+user.id-2).hours
  #     min = 5
  #     max = 20
  #     map_location = "421 w gilman st, madison, wi"
  #     @event = user.events.build(
  #                       id: id,
  #                       title: title,
  #                       description: description,
  #                       starts_at: starts_at,
  #                       ends_at: ends_at,
  #                       min: min,
  #                       max: max,
  #                       map_location: map_location
  #                       )
  #     @event.save
  #     rsvps1.each do |r|
  #       if r!=user.id
  #         r.rsvp!(@event)
  #       end
  #     end
  #     if(e > 2)
  #       rsvps2.each do |r2|
  #         if r2 != user.id
  #           r2.rsvp!(@event)
  #         end
  #       end
  #     end
  # end
#   end
# end

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
