class User < ActiveRecord::Base
  default_scope :order => 'name'
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
                  :digest,
                  :notify_event_reminders,
                  :city,
                  :post_to_fb_wall,
                  :avatar,
                  :vendor,
                  :family_filter,
                  :email_comments,
                  :follow_up,
                  :background

  has_attached_file :avatar, :styles => { :original => "150x150#",
                                          :raster => "50x50#" },
                             :convert_options => { :raster => '-quality 40' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "user/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png"

  has_attached_file :background, :styles => { :original => { :geometry => '1024x640#', :format => 'PJPEG' } },
                             :convert_options => { :original => '-interlace Plane', :original => '-quality 100' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "user/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/user/backgrounds/original/default_profile_pic.png"

  validates :background, #:attachment_presence => true,
                        :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] }
                            
  validates :avatar, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] },
                     :attachment_size => { :in => 0..350.kilobytes }

  validates :terms,
            :name, 
            :time_zone, presence: true

  validates :city, presence: true if Rails.env.production?

  has_many :authentications, :dependent => :destroy, :uniq => true

  has_many :events, :dependent => :destroy
  has_many :suggestions

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
  has_many :comments

  after_create :send_welcome

  HOOSIN = +16088074732
  
  def as_json(options = {})
    if self.authentications.where(:provider == "Facebook").any?
      @pic_url = self.authentications.find_by_provider("Facebook").pic_url
    else
      @pic_url = self.avatar.url
    end
   {
    :uid => self.id,
    :first_name => self.first_name,
    :last_name => self.last_name,
    :pic_url => @pic_url
    #:email_hex => Digest::MD5::hexdigest(self.email.downcase)
    #:profile_pic_url => "https://secure.gravatar.com/avatar/#{Digest::MD5::hexdigest(user.email.downcase)}?s=50"
    }
  end

  def first_name
    name.split(' ')[0]
  end

  def last_name
    name.split.count == 3 ? name.split(' ')[2] : name.split(' ')[1]
  end

  def middle_name
    name.split.count == 3 ? name.split(' ')[1] : nil
  end

  def send_welcome
    if vendor?
      Notifier.delay.vendor_welcome(self)
    else
      Notifier.delay.welcome(self)
    end
  end

  def self.search(query)
    conditions = <<-EOS
      to_tsvector('english', 
        coalesce(name, '') || ' ' || coalesce(email, '')
      ) @@ plainto_tsquery('english', ?)
    EOS

    where(conditions, query)
  end

  def cloned?(suggestion_id)
    if events.find_by_suggestion_id(suggestion_id)
      return true
    else
      return false
    end
  end

  def rsvpd_to_clone?(suggestion_id)
    @event = events.find_by_suggestion_id(suggestion_id)
    if @event.nil?
      return false
    else
      if rsvps.find_by_plan_id(@event.id).nil?
        return false
      else
        return true
      end
    end
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
      return flash[:notice] = "The event is currently full."
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
    unless relationships.find_by_followed_id(other_user.id).nil?
      relationships.find_by_followed_id(other_user.id).destroy
    end
  end

  def friend!(other_user)
    if other_user.require_confirm_follow? && other_user.following?(self) == false #autoconfirm if already following us 
      self.follow!(other_user)
      @relationship = self.relationships.find_by_followed_id(other_user.id) #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
      @relationship.confirmed = false
      @relationship.save
      Notifier.delay.confirm_follow(other_user, self)
    else
      unless self.following?(other_user) || self.request_following?(other_user)
        self.follow!(other_user)
      end
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      @relationship.confirmed = true
      @relationship.save
      Notifier.delay.new_friend(other_user, self)
      self.friend_back!(other_user)
    end
  end

  def friend_back!(other_user)
    unless other_user.following?(self) || other_user.vendor?
      unless other_user.request_following?(self) 
        other_user.follow!(self)
      end
      @reverse_relationship = other_user.relationships.find_by_followed_id(self.id)
      @reverse_relationship.confirmed = true
      @reverse_relationship.save
      other_user.add_invitations_from_user(self)
      #also need to add all relevant invitations for both people at this point
    end
  end

  def add_invitations_from_user(other_user)
    other_user.rsvps.each do |r|
      if r.invite_all_friends?
        unless self.invited?(r.plan) || r.plan.starts_at < (Time.now - 3.days)
          other_user.invite!(r.plan, self)
        end
      end
    end
  end

  def delete_invitations_from_user(other_user)
    self.invitations.where('invitations.inviter_id = :other_user_id',
                             other_user_id: other_user.id).each do |i|
      e = Event.find_by_id(i.invited_event_id)
      unless e.nil? || self.invited?(e)
        self.find_alternate_invitation_to_event(e)
      end
      i.destroy
    end
  end

  def find_alternate_invitation_to_event(event)
    event.rsvps.each do |r|
      if r.invite_all_friends? && self.following?(r.guest)
        r.guest.invite!(event, self)
        return
      end
    end
  end

  def invited?(event)
    #Invite.where(invited_event_id: event.id, invited_user_id: self.id).any?
    invitations.where('invitations.invited_event_id = :eventid', eventid: event.id).any?
  end

  def invited_to_an_events_group?(parent_event)
    if parent_event.groups.any?
      parent_event.groups.each do |child|
        if invitations.where('invitations.invited_event_id = :eventid', eventid: child.id).any?
          return true
        end
      end
    end
    return false
  end

  def made_a_group?(parent_event)
    self.events.each do |e|
      parent_event.groups.each do |peg|
        if e.id == peg.id
          return true
        end
      end
    end
    return false
  end


  def invited_all_friends?(event)
    if self.rsvpd?(event)
      if self.rsvps.find_by_plan_id(event.id).invite_all_friends?
        return true
      end
    end
    return false
  end
  
  def invite_all_friends!(event)
    self.followers.each do |f|
      unless f.invited?(event)
        self.invite!(event, f)
      end
    end
    if self.rsvpd?(event)
      r = self.rsvps.find_by_plan_id(event.id)
      r.invite_all_friends = true
      r.save
    end
  end

  def invite!(event, other_user)
    other_user.invitations.create!(invited_event_id: event.id, inviter_id: self.id)
    other_user.new_invited_events_count += 1
    other_user.save
  end

  def forecast(load_datetime, plan_counts, invite_counts)
    Time.zone = self.time_zone
    @forecast = []
    (-3..16).each do |i|
      @events = []
      @new_datetime = load_datetime + i.days #Date.strptime(load_date, "%Y-%m-%d") + i
      @plan_count = []
      @invite_count = []
      @events_on_date = self.events_on_date(@new_datetime, @plan_count, @invite_count)
      @events_on_date = @events_on_date.sort_by{|t| t[:starts_at]}
      @events_on_date.each do |e|
        @events.push(e)
      end
      plan_counts.push(@plan_count[0])
      invite_counts.push(@invite_count[0])
      @forecast.push(@events)
    end
    return @forecast
  end

  def events_on_date(load_datetime, plan_count, invite_count)
    #usable_date = load_datetime.in_time_zone("Central Time (US & Canada)")
    # usable_date = load_datetime# - 4.hours
    # adjusted_load_date = usable_date.to_date
    Time.zone = self.time_zone
    time_range = load_datetime.midnight .. load_datetime.midnight + 1.day
    @plans_on_date = Event.where(starts_at: time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: self.id}).order("starts_at ASC")
    @plans_on_date.each do |p|
      p.inviter_id = p.user.id
    end
    @invited_events_on_date = Event.where(starts_at: time_range).joins(:invitations)
                              .where(invitations: {invited_user_id: self.id}).order("starts_at ASC")
    @invited_events_on_date = @invited_events_on_date - @plans_on_date
    @invited_events_on_date.each do |ie|
      ie.inviter_id = ie.invitations.find_by_invited_user_id(self.id).inviter_id
    end
    invite_count.push(@invited_events_on_date.count)
    plan_count.push(@plans_on_date.count)

    return @invited_events_on_date | @plans_on_date
  end

  def mobile_events_on_date(load_datetime)#don't care about toggled here, do it locally on client

    Time.zone = self.time_zone
    time_range = load_datetime.midnight .. load_datetime.midnight + 1.day
    @plans_on_date = Event.where(starts_at: time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: self.id}).order("starts_at ASC")
    @plans_on_date.each do |p|
      p.inviter_id = p.user.id
    end

    @invited_events_on_date = Event.where(starts_at: time_range).joins(:invitations)
                              .where(invitations: {invited_user_id: self.id}).order("starts_at ASC")
    
    @invited_events_on_date = @invited_events_on_date - @plans_on_date
    
    @invited_events_on_date.each do |ie|
      ie.inviter_id = ie.invitations.find_by_invited_user_id(self.id).inviter_id
    end
    return @invited_events_on_date | @plans_on_date
  end

  def self.digest
    @day = Date.today.days_to_week_start
    if @day == 0 || @day == 2 || @day == 4
      @digest_users = User.where("users.digest = 'true'")
      @digest_users.each do |u|
        time_range = Time.now.midnight .. Time.now.midnight + 3.days
        if u.events.where(starts_at: time_range).any?
          @upcoming_events = []
          (0..2).each do |day|
            @date = Date.today + day.days
            @events = u.events_on_date(@date, [], [])
            @upcoming_events.push(@events)
          end
          Notifier.delay.digest(u, @upcoming_events)
        else
          @user_invitations = u.invitations.find(:all, order: 'created_at desc')
          if @user_invitations.any?
            @new_events = []
            @user_invitations.each do |ui|
              e = Event.find_by_id(ui.invited_event_id)
              if e.starts_at.between?(Time.now.midnight, Time.now.midnight + 3.days)
                @new_events.push(e)
              end
            end
            if @new_events.any?
              @upcoming_events = []
              (0..2).each do |day|
                @date = Date.today + day.days
                @events = u.events_on_date(@date, [], [])
                @upcoming_events.push(@events)
              end
              Notifier.delay.digest(u, @upcoming_events)
            end
          end
        end
      end
    end
  end

  def self.follow_up
    @fu_events = Event.where(starts_at: Time.now.midnight - 1.day .. Time.now.midnight, tipped: true)
    if @fu_events.any?
      @fu_events.each do |fue|
        @fu_recipients = fue.guests.select{ |g| g.follow_up? }
        @fu_recipients.each do |fur|
          @new_friends = []
          fue.guests.each do |g|
            if !fur.following?(g) && fur != g
              @new_friends.push(g)
            end
          end
          if @new_friends.any?
            Notifier.delay.follow_up(fur, fue, @new_friends)
          end
        end
      end
    end
  end

  def vendor_friendships
    @vendor_friendships = []
    self.relationships.where('relationships.confirmed = true').each do |r|
      if r.followed.vendor?
        @vendor_friendships << r
      end
    end
    return @vendor_friendships
  end

  def fb_user?
    if self.authentications.find_by_provider("Facebook")
      return true
    else
      return false
    end
  end

  def fb_friends(graph)
    #RETURNS AN ARRAY [[HOOSIN_USERS][NOT_HOOSIN_USERS(FB_USERS)]]
    @fb_friends = []
    
    @hoosin_user = []
    @not_hoosin_user = []
    @graph = graph
    @facebook_friends = @graph.fql_query("select current_location, pic_square, name, username, uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())")
    @city_friends = @facebook_friends.reject { |ff| !ff['current_location'] || ff['current_location']['name'] != self.city } 
    @city_friends.each do |cf|
      @authentication = Authentication.find_by_uid("#{cf['uid']}")
      if @authentication
        user = @authentication.user
        @hoosin_user << user
      else
        @not_hoosin_user << cf
      end
    end
    @fb_friends << @hoosin_user
    @fb_friends << @not_hoosin_user
    return @fb_friends
  end

  def permits_wall_posts?(graph)
    @publish = graph.fql_query("select publish_stream from permissions where uid = me()")
    if @publish[0]["publish_stream"] == 1
      return true
    else
      return false
    end
  end

  # CONTACT FOR INVITATION
  # def contact(event)
  #   if app user
  #     push notification
  #   elsif phone number && allows texts
  #     Twilio::SMS.create :to => '#{self.phone}', :from => 'HOOSIN',
  #                 :body => "#{event.title - event.short_url}"
  #   elsif allows emails
  #     email
  #   end
  # end

  # contact for digest
  # contact for s/o rsvped to their event
  # contact for 

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
