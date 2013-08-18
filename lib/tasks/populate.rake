namespace :db do
  desc "Erase and fill database with sample data"
  task populate: :environment do
    require 'populator'
    require 'faker'
    
    [User, Event, Comment, Instance, Invitation, Relationship, Rsvp, InstanceRsvp].each(&:delete_all)
    
    City.create(name:"Madison, WI", timezone:'Central Time (US & Canada)')
    adam = User.create!(name:"Adam Braus", email: "ajbraus@gmail.com", city: City.find_by_name("Madison, WI"), password:"password", terms:"true", confirmed_at: Time.now)
    test = User.create!(name:"Test One", email: "test@one.com", city: City.find_by_name("Madison, WI"), password:"password", terms:"true", confirmed_at: Time.now)

    Relationship.create!(follower_id: adam.id, followed_id: test.id, status: 2)
    adam.friends_count += 1
    adam.save
    Relationship.create!(follower_id: test.id, followed_id: adam.id, status: 1)
    test.friended_bys_count += 1
    test.save

    User.populate 30..50 do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.city_id = City.find_by_name("Madison, WI").id
      user.encrypted_password = "password"
      user.terms = true
      user.confirmed_at = Time.now

      # TODO POPULATE RELATIONSHIPS

      Event.populate 0..6 do |event|
        event.title = Populator.words(7..18).titleize
        event.description = Populator.words(15..50)
        event.user_id = user.id
        event.visibility = 2
        event.city_id = City.find_by_name("Madison, WI").id
        event.slug = event.id

        Comment.populate 3..7 do |comment|
          comment.event_id = event.id
          comment.content = Populator.words(3..14)
          comment.user_id = User.all.sample.id
        end
      end
    end
    
    # user  = User.find_by_email("ajbraus@gmail.com")
    # followed_users = User.all[2..50]
    # followers      = User.all[3..40]
    # followed_users.each { |followed| user.inmate!(followed) }
    # followers.each      { |follower| follower.friend!(user) }
  end
end

# def make_events
#   users = User.all(limit: 7)
#   rsvps1 = users[0..3]
#   rsvps2 = users[4..6]
#   5.times do |e|
#     id = e
#     title = "Public Fun #{e+1}"
#     starts_at = Time.now + (e).days - (e).hours
#     ends_at = Time.now + (e).days - (e-2).hours
#     address = "location location #{e+1}"
#     promo_url = "http://uhaweb.hartford.edu/aschmidt/kitten11.jpg"
#     min = 2
#     max = 20
#     is_public = true
#     @event = users[e].events.build(
#                         id: id,
#                         title: title,
#                         starts_at: starts_at,
#                         ends_at: ends_at,
#                         min: min,
#                         max: max,
#                         is_public:is_public
#                         )
#     @event.save
#     users[e+1].rsvp_in!(@event)
#   end
# end