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
                  :name,
                  :terms,
                  :require_confirm_follow,
                  :allow_contact,
                  :digest,
                  :notify_event_reminders,
                  :city_id,
                  :city,
                  :post_to_fb_wall,
                  :avatar,
                  :vendor,
                  :family_filter,
                  :email_comments,
                  :follow_up,
                  :background,
                  :type,
                  :street_address,
                  :postal_code,
                  :country,
                  :phone_number,
                  :account_uri,
                  :bank_account_uri,
                  :credits_uri,
                  :credit_card_uri,
                  :debits_uri

  has_attached_file :avatar, :styles => { :original => "150x150#",
                                          :raster => "50x50#" },
                             :convert_options => { :raster => '-quality 40' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "user/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png"

  has_attached_file :background, :styles => { :original => { :geometry => '1024x640#', :format => 'PJPEG' } },
                             :convert_options => { :original => '-interlace Plane', :original => '-quality 80' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "user/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/user/backgrounds/original/default_profile_pic.png"

  validates :background, #:attachment_presence => true,
                        :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] }
                            
  validates :avatar, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] },
                     :attachment_size => { :in => 0..350.kilobytes }

  # Normalizes the attribute itself before 
  #phony_normalize :phone_number, :default_country_code => 'US'
  #phony_normalize :phone_number, :as => :phone_number_normalized_version, :default_country_code => 'US' 
  #validates :phone_number, :phony_plausible => true
  #phony_normalized_method :phone_number, :default_country_code => 'US'
  
  validates :terms,
            :name, 
            :city_id, presence: true

  has_many :authentications, :dependent => :destroy, :uniq => true

  has_many :events, :dependent => :destroy

  has_many :rsvps, foreign_key: "guest_id", dependent: :destroy
  has_many :plans, through: :rsvps, :conditions => ['inout = ?', 1]

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy

  has_many :inmates, through: :relationships, source: :followed, conditions: "status = 1"  
  has_many :friends, through: :relationships, source: :followed, conditions: "status = 2"  

  has_many :comments, dependent: :destroy

  belongs_to :city

  after_create :send_welcome

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end


  HOOSIN = +16088074732
  
  def city_name
    city.try(:name)
  end

  def city_name=(name)
    self.city = City.find_by_name(name) if name.present?
  end

  def as_json(options = {})
    if self.authentications.where(:provider == "Facebook").any?
      @pic_url = self.authentications.find_by_provider("Facebook").pic_url
    else
      @pic_url = self.avatar.url
    end
    @guest_count = 0
    self.events.each do |e|
      @guest_count += (e.guests.count -1)
    end
   {
    :uid => self.id,
    :first_name => self.first_name,
    :last_name => self.last_name,
    :pic_url => @pic_url,
    :in_cnt => self.plans.count,
    :idea_cnt => self.events.count,
    :g_cnt => @guest_count
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

  def rsvpd?(event)
    @rsvp = rsvps.find_by_plan_id(event.id)
    if @rsvp.present?
      return true
    else
      return false
    end
  end

  def in?(event)  
    @rsvp = self.rsvps.find_by_plan_id(event.id)
    return @rsvp.present? && @rsvp.inout == 1
  end

  def out?(event)
    @rsvp = rsvps.find_by_plan_id(event.id)
    if @rsvp.present? && @rsvp.inout == 0
      return true
    elsif event.parent.present?
      @rsvp = rsvps.find_by_plan_id(event.parent.id)
      if @rsvp.present? && @rsvp.inout == 0
        return true
      end
    else
      return false
    end
  end

  def flake_out!(event)
    if event.rsvps.where(guest_id: self.id).any?
      @existing_rsvp = event.rsvps.where(guest_id: self.id).first
      @existing_rsvp.destroy
    end
  end

  #moved all parent logic into the model
  def rsvp_in!(event)
    if event.full?
      return flash[:notice] = "The event is currently full."
    else
      if event.rsvps.where(guest_id: self.id).any?
        @existing_rsvp = event.rsvps.where(guest_id: self.id).first 
        if @existing_rsvp.inout == 1
          return
        else
          @existing_rsvp.destroy
        end
      end
      rsvps.create!(plan_id: event.id, inout: 1)
      event.guests.each do |g|
        self.inmate!(g)
      end
      if event.parent.present?
        self.rsvp_in!(event.parent)
      else #contact only once if they sign up for time + idea 
        unless event.user == self
          event.user.delay.contact_new_rsvp(event, self)
        end
      end
    end
  end

  def rsvp_out!(event)
    if event.rsvps.where(guest_id: self.id).any?
      @existing_rsvp = event.rsvps.where(guest_id: self.id).first 
      @existing_rsvp.destroy
    end
    rsvps.create!(plan_id: event.id, inout: 0)
    event.instances.each do |time|
      self.rsvp_out!(time)
    end
  end

  #get user's profile picture
  def profile_picture_url
    if self.authentications.where(:provider == "Facebook").any?
      "#{user.authentications.find_by_provider("Facebook").pic_url}"
    else
      if self.avatar.url.nil?
        "https://s3.amazonaws.com/hoosin-production/user/avatars/raster/default_profile_pic.png"
      else
        self.avatar.url(:raster)
      end
    end
  end 


  #Relationship methods
  def is_friends_with?(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present? && @relationship.status == 2
      return true
    end
    return false
  end

  def friended_by?(other_user)
    @relationship = other_user.relationships.find_by_followed_id(self.id)
    if @relationship.present? && @relationship.status == 2
      return true
    end
    return false
  end

  def ignores?(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present? && @relationship.status == 0
      return true
    end
    return false
  end

  def is_inmates_with?(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present? && @relationship.status == 1
      return true
    end
    return false
  end

  def is_inmates_or_friends_with?(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present?
      unless @relationship.status == 0
        return true
      end
    end
    return false
  end

  def friend!(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present?
      @relationship.status = 2
      @relationship.save
    else 
      self.inmate!(other_user)
      self.friend!(other_user)
    end
  end

  def inmate!(other_user)
    unless self.is_inmates_with?(other_user) || other_user.ignores?(self) || self.is_friends_with?(other_user) || self.id == other_user.id
      self.relationships.create(followed_id: other_user.id, status: 1)
    end
    unless other_user.is_inmates_with?(self) || self.ignores?(other_user) || other_user.is_friends_with?(self)
      other_user.relationships.create(followed_id: self.id, status: 1)
    end
  end

  def ignore_inmate!(inmate)
    @reverse_relationship = inmate.relationships.find_by_followed_id(self.id)
    @reverse_relationship.status = 0
    @reverse_relationship.save

    @relationship = self.relationships.find_by_followed_id(inmate.id)
    @relationship.status = 0
    @relationship.save
  end

  def unfriend!(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present?
      @relationship.status = 1
      @relationship.save
    end
  end

  def invited?(event)
    if event.friends_only?
      return event.user.is_friends_with?(self)
    else
      event.guests.each do |g|
        if g.is_inmates_or_friends_with?(self)
          return true
        end
      end
    end
    return false
  end

  def add_fb_to_inmates
    @member_friends = self.fb_friends(@graph)[0]
    @member_friends.each do |mf|
      self.inmate!(mf)
    end
  end

  # Contact methods
  def contact_reminder(event)
    @user = self
    @event = event
    if @user.iPhone_user == true
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
          n = APN::Notification.new
          n.device = d
          n.alert = "#{@event.short_event_title} starts at #{@event.start_time_no_date}"
          n.badge = 1
          n.sound = true
          n.custom_properties = {:type => "reminder", :id => "#{@event.id}", msg: ""}
          n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.short_event_title} starts at #{@event.start_time_no_date}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:type => "reminder", :id => "#{@event.id}", :msg => ""}}
        n.save
      end
    else
      unless @user == User.find_by_email("info@hoos.in")
        Notifier.rsvp_reminder(@event, @user).deliver
      end
    end
  end

  def contact_new_time(event)
    @user = self
    @event = event
    @event_link = event_url(@event)

    if @user.iPhone_user?
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.user.first_name} set a time for #{@event.title} - #{@event.start_time}!"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:type => "time_change", :event => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.user.first_name} set a time for #{@event.title} - #{@event.start_time}!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{event.title} new time!"}}
        n.save
      end
    else
      Notifier.new_time(@event, @user).deliver
    end
  end

  def contact_time_change(event)
    @user = self
    @event = event
    @event_link = event_url(@event)

    if @user.iPhone_user?
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Time Change"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:msg => "#{@event.short_event_title} - #{@event.start_time_no_date}", 
                                :type => "time_change", 
                                :id => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Time Change"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:msg => "#{@event.short_event_title} - #{@event.start_time_no_date}", 
                                                            :type => "time_change", 
                                                            :id => "#{@event.id}"}}
        n.save
      end
    else
      Notifier.time_change(event, @user).deliver
    end
  end

  def contact_comment(comment)
    @commenter = comment.user.name
    @comment = comment
    @event = @comment.event
    @comments = @event.comments.order('created_at DESC').limit(4)
    @comments.shift(1)
    @user = self
    if @user.iPhone_user?
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "New Comment - #{@event.short_event_title}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {msg: "from #{@commenter.name}", :type => "new_comment", :id => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "New Comment - #{@event.short_event_title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {msg: "from #{@commenter.name}", :type => "new_comment", :id => "#{@event.id}"}}
        n.save
      end
    else
      Notifier.email_comment(@comment, @user).deliver
    end
  end

  def contact_cancellation(event)
    @event = event
    @user = self
    if @user.iPhone_user?
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Cancellation - #{@event.event_day}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {msg: "#{@event.short_event_title}", :type => "cancel", :id => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Cancellation - #{@event.event_day}, #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {msg: "#{@event.short_event_title}", :type => "cancel", :id => "#{@event.id}"}}
        n.save
      end
    else 
      unless @user == @event.user
        Notifier.cancellation(@event, @user).deliver
      end
    end
  end

  def contact_friend(friend)
    @user = self
    @follower = friend
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "New Friend - #{@follower.name}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {msg: "", :type => "new_friend", :id => "#{@follower.id}"}
        n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "New Friend - #{@follower.name}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {msg: "", :type => "new_friend", :id => "#{@follower.id}"}}
        n.save
      end
    else
      #@follower_pic = raster_profile_picture(@user)
      Notifier.new_friend(@user, @follower).deliver
    end
  end

  #changed this to keep consistence with these all being contact to
  #user object that is calling the method
  def contact_new_rsvp(event, rsvp_user)
    @event = event
    @rsvping_user = rsvp_user
    @user = self
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "New .in - #{@rsvping_user.name} for #{@event.title}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {msg: "", :type => "new_rsvp", :id => "#{@rsvping_user.id}"}
        n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "New .in - #{@rsvping_user.name} for #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMtoken], :data => {msg: "", :type => "new_rsvp", :id => "#{@rsvping_user.id}"}}
        n.save
      end
    else
      Notifier.new_rsvp(@user, @rsvping_user).deliver
    end
  end

  # Class Methods
  def self.digest
    @day = Date.today.days_to_week_start
   if @day == 0 || @day == 4
      @digest_users = User.where("users.digest = 'true'")
      @digest_users.each do |u|
        @now_in_zone = Time.now.in_time_zone(u.city.timezone)
        time_range = @now_in_zone.midnight .. @now_in_zone.midnight + 3.days
        @has_events = false
        @upcoming_events = []
        (0..2).each do |day|
          day_time_range = @now_in_zone.midnight + day.days .. @now_in_zone.midnight + (day+1).days
          @upcoming_day_events = u.plans.where(starts_at: day_time_range)
          if @upcoming_day_events.any?
            @has_events = true
          end
          @upcoming_events.push(@upcoming_day_events)
        end
        @invited_events = []
        (0..2).each do |day|
          day_time_range = @now_in_zone.midnight + day.days .. @now_in_zone.midnight + (day+1).days
          @day_invited_events = u.invited_events.where(starts_at: day_time_range)
          if @day_invited_events.any?
            @has_events = true
          end
          @invited_events.push(@day_invited_events)
        end
        @new_invite_ideas = Event.where('events.ends_at IS NULL AND events.created_at > ?', @now_in_zone - 4.days).joins(:invitations).where(invitations: {invited_user_id: u.id}).order("RANDOM()")
        @all_new_city_ideas = Event.where('events.ends_at IS NULL AND events.is_public = ? AND events.city_id = ? AND events.created_at > ?', true, u.city_id, @now_in_zone - 4.days)
        @new_city_ideas = @all_new_city_ideas.first(5)
        if @has_events == true || @new_invite_ideas.any? || @new_city_ideas.any?
          Notifier.delay.digest(u, @invited_events, @upcoming_events, @has_events, @new_invited_ideas, @new_city_ideas, @all_new_city_ideas.count)
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

  def self.check_for_new_fb_member_friends
    #add all facebook friends to inmates (create relationships with status = 1) 
    #check if session token is still valid
    @member_friends = self.fb_friends(session[:graph])[0]
    @member_friends.each do |mf|
      u.inmate!(mf)
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
    @city_friends = @facebook_friends.reject { |ff| !ff['current_location'] || ff['current_location']['name'] != self.authentications.select{|auth| auth.provider == "Facebook"}.first.city } 
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
    if graph.nil?
      return false
    else
      @publish = graph.fql_query("select publish_stream from permissions where uid = me()")
      if @publish[0]["publish_stream"] == 1
        return true
      else
        return false
      end
    end
  end

  def has_valid_credit_card?
    if credit_card_uri.blank?
      return false
    else
      return true 
    end
  end

  def credit!(user, amount)
    bank_account = Balanced::BankAccount.find(user.bank_account_uri)
    bank_account.credit(amount)
  end

  def refund!(amount)
    
  end

  def fb_authentication
    @auth = authentications.where("provider = ?", "Facebook").last
    return @auth
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
