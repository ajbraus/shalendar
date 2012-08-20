class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :omniauthable, :token_authenticatable

  before_save :ensure_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, 
  								:password, 
  								:password_confirmation, 
  								:remember_me, 
                  :first_name,
                  :last_name,
                  :name,
                  :terms,
                  :provider,
                  :uid,
                  :require_confirm_follow,
                  :notify_noncritical_change,
                  :daily_digest,
                  :notify_event_reminders,
                  :city


  validates :terms,
            :name, presence: true

  has_many :events, :dependent => :destroy
  
  has_many :rsvps, foreign_key: "guest_id", dependent: :destroy
  has_many :plans, through: :rsvps


  has_many :relationships, foreign_key: "follower_id", dependent: :destroy

  has_many :followed_users, through: :relationships, source: :followed, conditions: "confirmed = 't'"
  has_many :pending_followed_users, through: :relationships, source: :followed, conditions: "confirmed = 'f'"
  

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower, conditions: "confirmed = 't'"
  has_many :pending_followers, through: :reverse_relationships, source: :follower, conditions: "confirmed = 'f'"

  after_create :send_welcome
  
  def as_json(options = {})
   {
    :id => self.id,
    :first_name => self.first_name,
    :last_name => self.last_name
    }
  end

  def send_welcome
     Notifier.welcome(self).deliver
  end

  # Search indexes

  # define_index do
  #   # fields
  #   indexes email, :sortable => true
  #   indexes name, :sortable => true
    
  #   # attributes
  #   has author_id, created_at, updated_at
  # end

  #Rsvp methods... user.plans = list of events
  def rsvpd?(event)
    rsvps.find_by_plan_id(event.id)
  end

  def rsvp!(event)
    if event.full?
      flash[:notice] = "The event is currently full."
    else
      rsvps.create!(plan_id: event.id)
    end
  end

  def unrsvp!(event)
    if event.guests.count == event.min
      #Warning: this will un-tip the event for everyone, are you sure?
    end
    rsvps.find_by_plan_id(event.id).destroy
  end

  def current_user?(user)
    user == current_user
  end

  #Relationship methods
  def following?(other_user)
    if r = relationships.find_by_followed_id(other_user.id)
      if r.confirmed?
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def request_following?(other_user)
    if r = relationships.find_by_followed_id(other_user.id)
      if r.confirmed?
        return false
      else
        return true
      end
    else
      return false
    end
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end


#OAUTH METHOD
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(  name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20],
                           terms: 't',
                           city:auth.info.location
                           )
    end
    user
  end

# https://github.com/pantulis/devise-omniauth-only-twitter/blob/master/app/models/user.rb

  # has_many :authentications
  
  # def self.find_for_twitter_oauth(omniauth)
  #   authentication = Authentication.find_by_provider_and_uuid(omniauth['provider'], omniauth['uid'])
  #   if authentication && authentication.user
  #     authentication.user
  #   else
  #     user = User.create!(:nickname => omniauth['nickname'], 
  #                           :name => omniauth['name'])
  #     user.authentications.create!(:provider => omniauth['provider'], :uuid => omniauth['uid'])
  #     user.save
  #     user
  #   end
  # end

  #AUX methods

  def first_name
    name.split(' ')[0]
  end

  def last_name
    name.split.count == 3 ? name.split(' ')[2] : name.split(' ')[1]
  end

  def middle_name
    name.split.count == 3 ? name.split(' ')[1] : nil
  end
  
  def morning_plans_on_date(load_date)
    @plans = self.plans
    @morning_plans = []
    @plans.each do |p|
      if p.starts_at.to_date == load_date
        if p.starts_at < load_date.to_s + " 12:00:00"
          @morning_plans.push(p)
        end
      end
    end
    return @morning_plans
  end

  def afternoon_plans_on_date(load_date)
    @plans = self.plans
    @afternoon_plans = []
    @plans.each do |p|
      if p.starts_at.to_date == load_date
        if p.starts_at >= load_date.to_s + " 12:00:00" && p.starts_at < load_date.to_s + " 18:00:00"
          @afternoon_plans.push(p)
        end
      end
    end
    return @afternoon_plans
  end

  def evening_plans_on_date(load_date)
    @plans = self.plans
    @evening_plans = []
    @plans.each do |p|
      if p.starts_at.to_date == load_date
        if  p.starts_at >= load_date.to_s + " 18:00:00"
          @evening_plans.push(p)
        end
      end
    end
    return @evening_plans
  end

  def morning_maybes_on_date(load_date)
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :current_user_email', current_user_email: self.email)
    @toggled_morning_invitation_events = []

    @invitation_events.each do |ie|
      if fp.starts_at.to_date == load_date
        if fp.starts_at < load_date.to_s + " 12:00:00"
          unless self.rsvpd?(ie) || self == ie.user
            if self.following?(ie.user)
              if self.relationships.find_by_followed_id(ie.user).toggled?
                @toggled_morning_invitation_events.push(ie)
              end
            else
              @toggled_morning_invitation_events.push(ie)
            end
          end
        end
      end
    end

    @morning_maybe_events = []
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :current_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :current_user_id => self.id) 

    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        if fp.starts_at.to_date == load_date
          if fp.starts_at < load_date.to_s + " 12:00:00"
            unless fp.full? || fp.visibility == "invite_only" || self.rsvpd?(fp)
              if fp.user == f || fp.visibility == "friends_of_friends"
                @morning_maybe_events.push(fp)
              end
            end
          end
        end
      end
    end

    @morning_maybes_on_date = @morning_maybe_events | @toggled_morning_invitation_events
    return @morning_maybes_on_date

  end

  def afternoon_maybes_on_date(load_date)
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :current_user_email', current_user_email: self.email)
    @toggled_afternoon_invitation_events = []

    @invitation_events.each do |ie|
      if fp.starts_at.to_date == load_date
        if fp.starts_at >= load_date.to_s + " 12:00:00" && fp.starts_at < load_date.to_s + " 18:00:00"
          unless self.rsvpd?(ie) || self == ie.user
            if self.following?(ie.user)
              if self.relationships.find_by_followed_id(ie.user).toggled?
                @toggled_afternoon_invitation_events.push(ie)
              end
            else
              @toggled_afternoon_invitation_events.push(ie)
            end
          end
        end
      end
    end

    @afternoon_maybe_events = []
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :current_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :current_user_id => self.id) 

    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        if fp.starts_at.to_date == load_date
          if fp.starts_at >= load_date.to_s + " 12:00:00" && fp.starts_at < load_date.to_s + " 18:00:00"
            unless fp.full? || fp.visibility == "invite_only" || self.rsvpd?(fp)
              if fp.user == f || fp.visibility == "friends_of_friends"
                @afternoon_maybe_events.push(fp)
              end
            end
          end
        end
      end
    end

    @afternoon_maybes_on_date = @afternoon_maybe_events | @toggled_afternoon_invitation_events
    return @afternoon_maybes_on_date

  end

  def evening_maybes_on_date(load_date)
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :current_user_email', current_user_email: self.email)
    @toggled_evening_invitation_events = []

    @invitation_events.each do |ie|
      if fp.starts_at.to_date == load_date
        if fp.starts_at >= load_date.to_s + " 18:00:00"
          unless self.rsvpd?(ie) || self == ie.user
            if self.following?(ie.user)
              if self.relationships.find_by_followed_id(ie.user).toggled?
                @toggled_evening_invitation_events.push(ie)
              end
            else
              @toggled_evening_invitation_events.push(ie)
            end
          end
        end
      end
    end

    @evening_maybe_events = []
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :current_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :current_user_id => self.id) 

    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        if fp.starts_at.to_date == load_date
          if fp.starts_at >= load_date.to_s + " 18:00:00"
            unless fp.full? || fp.visibility == "invite_only" || self.rsvpd?(fp)
              if fp.user == f || fp.visibility == "friends_of_friends"
                @evening_maybe_events.push(fp)
              end
            end
          end
        end
      end
    end

    @evening_maybes_on_date = @evening_maybe_events | @toggled_evening_invitation_events
    return @evening_maybes_on_date
  end

  # def plans_on_date(load_date)
  #   @plans = self.plans
  #   @plans_on_date = []
  #   @plans.each do |p|
  #     if p.starts_at.to_date == load_date
  #       @plans_on_date.push(p)
  #     end
  #   end
  #   return @plans_on_date
  # end

  # def maybes_on_date(load_date)
  #   @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
  #                               .where('invites.email = :current_user_email', current_user_email: self.email)
  #   @toggled_invitation_events = []

  #   @invitation_events.each do |ie|
  #     if fp.starts_at.to_date == load_date
  #       unless self.rsvpd?(ie) || self == ie.user
  #         if self.following?(ie.user)
  #           if self.relationships.find_by_followed_id(ie.user).toggled?
  #             @toggled_invitation_events.push(ie)
  #           end
  #         else
  #           @toggled_invitation_events.push(ie)
  #         end
  #       end
  #     end
  #   end

  #   @maybe_events = []
  #   @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
  #                                   .where('relationships.follower_id = :current_user_id AND 
  #                                     relationships.toggled = true AND relationships.confirmed = true',
  #                                     :current_user_id => self.id) 

  #   @toggled_followed_users.each do |f|
  #     f.plans.each do |fp| #for friends of friends events that are RSVPd for
  #       unless fp.full? || fp.visibility == "invite_only" || self.rsvpd?(fp)
  #         if fp.user == f || fp.visibility == "friends_of_friends"
  #           if fp.starts_at.to_date == load_date
  #             @maybe_events.push(fp)
  #           end
  #         end
  #       end
  #     end
  #   end

  #   @maybes_on_date = @maybe_events | @toggled_invitation_events
  #   return @maybes_on_date
  # end


  private

  def password_required? 
    new_record? 
  end 


  # def graph
  #   @graph ||= Koala::Facebook::API.new(self.fb_token)
  # end

  # def fb_me
  #   graph.get_object('me')
  # end

  # def fb_friends(fields)
  #   graph.get_connections('me','friends',:fields => fields)
  # end

  # def fb_city_friends
  #   @friends_location = fb_friends("location")
  #   @friends_location.select do |friend|
  #     friend['location'].present? && friend['location']['name'] == fb_me['location']['name']
  #   end
  # end

  # def city_members
  #   User.where('uid IN (?)', fb_city_friends.map {|friend| friend['id']} ) 
  # end

end
