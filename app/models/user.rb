class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :omniauthable, :token_authenticatable

  before_save :ensure_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id,
                  :email, 
  								:password, 
  								:password_confirmation, 
  								:remember_me, 
                  :time_zone,
                  :name,
                  :terms,
                  :require_confirm_follow,
                  :allow_contact,
                  :notify_event_reminders,
                  :city,
                  :post_to_fb_wall,
                  :avatar

  has_attached_file :avatar, :styles => { :original => "50x50#" },
                             :convert_options => { :original => '-quality 40' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "user/:attachment/:style/:id" 

                            
  validates :avatar, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] },
                     :attachment_size => { :in => 0..150.kilobytes }

  validates :terms,
            :name, 
            :time_zone, presence: true

  validates :city, presence: true if Rails.env.production?

  has_many :authentications, :dependent => :destroy, :uniq => true

  has_many :events, :dependent => :destroy
  
  has_many :rsvps, foreign_key: "guest_id", dependent: :destroy
  has_many :plans, through: :rsvps

  has_many :invitations, foreign_key: "invited_user_id", dependent: :destroy
  has_many :invited_events, through: :invitations

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
    :uid => self.id,
    :first_name => self.first_name,
    :last_name => self.last_name,
    :email_hex => Digest::MD5::hexdigest(self.email.downcase)
    #:profile_pic_url => "https://secure.gravatar.com/avatar/#{Digest::MD5::hexdigest(user.email.downcase)}?s=50"
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

  def self.search(query)
    conditions = <<-EOS
      to_tsvector('english', 
        coalesce(name, '') || ' ' || coalesce(email, '')
      ) @@ plainto_tsquery('english', ?)
    EOS

    where(conditions, query)
  end


  def rsvpd?(event)
    if(rsvps.find_by_plan_id(event.id))
      return true
    else
      return false
    end
  end

  def rsvp!(event)
    if event.full?
      flash[:notice] = "The event is currently full."
    else
      rsvps.create!(plan_id: event.id)
    end
  end

  def unrsvp!(event)
    if event.guests.count == event.min #not letting it untip anymore
      #Warning: this will un-tip the event for everyone, are you sure?
    end
    rsvps.find_by_plan_id(event.id).destroy
  end

  def current_user?(user)
    user == current_user
  end

  def invited?(event)
    # return Invitation.where('invitations.invited_user_id = :current_user_id AND invitations.invited_event_id = :eventid',
    #                               current_user_id: self.id, eventid: event.id).any?
    invitations.where('invitations.invited_event_id = :eventid', eventid: event.id).any?
    #return Invite.where('invites.email = :current_user_email AND invites.event_id = :eventid',
    #              current_user_email: self.email, eventid: event.id).any?
    #if an invite for user at event exists
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
    unless self == other_user
      relationships.create!(followed_id: other_user.id)
    end
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

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

  def invite_all_friends!(event)
    self.followers.each do |f|
      self.invite!(event, f)
    end
  end

  def invite!(event, other_user)
    other_user.invitations.create!(invited_event_id: event.id, inviter_id: self.id)
    other_user.new_invited_events_count += 1
  end

  def forecast(load_date, plan_counts, invite_counts)
    @forecast = []
    (-3..16).each do |i|
      @morning_events = []
      @afternoon_events = []
      @evening_events = []
      @new_date = Date.strptime(load_date, "%Y-%m-%d") + i
      @plan_count = []
      @invite_count = []
      @events_on_date = self.events_on_date(@new_date, @plan_count, @invite_count)

      @events_on_date.each do |e|
        if e.starts_at < e.starts_at.to_date + 12.hours
          @morning_events.push(e)
        elsif e.starts_at < e.starts_at.to_date + 18.hours
          @afternoon_events.push(e)
        else
          @evening_events.push(e)
        end
      end
      plan_counts.push(@plan_count[0])
      invite_counts.push(@invite_count[0])
      @daycast = [@morning_events, @afternoon_events, @evening_events]
      @forecast.push(@daycast)
    end
    return @forecast
  end

  def events_on_date(load_date, plan_count, invite_count)
    #usable_date = load_datetime.in_time_zone("Central Time (US & Canada)")
    # usable_date = load_datetime# - 4.hours
    # adjusted_load_date = usable_date.to_date

    @plans = self.plans
    @invited_events = self.invited_events - @plans

    @date_plans = []
    @plans.each do |p|
      if p.starts_at.to_date == load_date
        p.inviter_id = p.user.id
        @date_plans.push(p)
      end
    end

    @date_invited_events = []
    self.invitations.each do |i|
      e = Event.find_by_id(i.invited_event_id)
      if e.starts_at.to_date == load_date
        unless self.rsvpd?(e)
          e.inviter_id = i.inviter_id
          @date_invited_events.push(e)
        end
      end
    end
    invite_count.push(@date_invited_events.count)
    plan_count.push(@date_plans.count)

    return @date_invited_events | @date_plans
  end


  # def forecastoverview
  #   @forecastoverview = []
  #   (-3..16).each do |i|
  #     if self.time_zone
  #       @new_date = Time.now.in_time_zone(self.time_zone).to_date + i
  #     else
  #       @new_date = Date.today + i
  #     end
  #     @datecounts = []
      
  #     @ideacount = self.idea_count_on_date(@new_date)
  #     @plancount = self.plan_count_on_date(@new_date)
  #     @datecounts.push(@ideacount)
  #     @datecounts.push(@plancount)
  #     @forecastoverview.push(@datecounts)
  #   end
  #   return @forecastoverview
  # end

  # #these could be maintained on RSVP/unRSVP... maybe
  # def plan_count_on_date(load_date)
  #   @plancount = 0
  #   self.plans.each do |p|
  #     if p.starts_at.to_date == load_date
  #       @plancount = @plancount + 1
  #     end
  #   end
  #   return @plancount
  # end

  # def idea_count_on_date(load_date)
  #   @ideacount = 0

  #   @invitations = Invite.where('invites.email = :current_user_email', current_user_email: self.email)
  #   @invitations.each do |i|
  #     @ie = Event.find_by_id(i.event_id)
  #     if @ie.starts_at.to_date == load_date
  #       unless self.rsvpd?(@ie)
  #         @ideacount = @ideacount + 1
  #       end
  #     end
  #   end

  #   self.followed_users.each do |f|
  #     f.plans.each do |fp| #for friends of friends events that are RSVPd for
  #       if fp.starts_at.to_date == load_date
  #         unless fp.visibility == "invite_only" || self.rsvpd?(fp) || self.invited?(fp)
  #           if fp.user == f || fp.visibility == "friends_of_friends"
  #             @ideacount = @ideacount + 1
  #           end
  #         end
  #       end
  #     end
  #   end
  #   return @ideacount
  # end

  def mobile_events_on_date(load_date)#don't care about toggled here, do it locally on client
    #usable_date = load_datetime.in_time_zone("Central Time (US & Canada)")
    # usable_date = load_datetime# - 4.hours
    # adjusted_load_date = usable_date.to_date

    @my_events = self.events
    @date_events = []
    @my_events.each do |e|
      if e.starts_at.to_date == load_date #change starts_at to appropriate timezone
        @date_events.push(e)
      end
    end

    @plans = self.plans
    @date_plans = []
    @plans.each do |p|
      if p.starts_at.to_date == load_date
        @date_plans.push(p)
      end
    end

    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :current_user_email', current_user_email: self.email)
    @date_invitation_events = []

    @invitation_events.each do |ie|
      if ie.starts_at.to_date == load_date
        @date_invitation_events.push(ie)
      end
    end

    @date_ideas = []
    @followed_users = self.followed_users
    @followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        if fp.starts_at.to_date == load_date
          unless fp.full? || fp.visibility == "invite_only"
            if fp.user == f || fp.visibility == "friends_of_friends"
              @date_ideas.push(fp)
            end
          end
        end
      end
    end

    return @date_ideas | @date_invitation_events | @date_plans | @date_events
  end

  private

  def password_required? 
    new_record? 
  end

  def send_gcm_notification(message, params)
    if self.android_user == false
      logger.info("Tried to send gcm notification to non-android user")
      return
    end

    device = Gcm::Device.find_by_id(self.GCMdevice_id)
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = "updates_available"
    notification.delay_while_idle = true
    notification.data = { :data => message}
    notification.save

  end

end
