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

  has_many :rsvps, dependent: :destroy
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
  has_many :comments, dependent: :destroy

  has_many :interests, dependent: :destroy
  has_many :categories, through: :interests

  belongs_to :city

  has_one :classification, :class_name => "Category"

  after_create :send_welcome

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end


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
    @rsvp = rsvps.find_by_plan_id(event.id)
    if @rsvp.present?
      return true
    else
      return false
    end
  end

  def in?(event)
    @rsvp = rsvps.find_by_plan_id(event.id)
    if @rsvp.present? && @rsvp.inout == 1
      return true
    else
      return false
    end
  end

  def out?(event)
    @rsvp = rsvps.find_by_plan_id(event.id)
    if @rsvp.present? && @rsvp.inout == 0
      return true
    else
      return false
    end
  end

  def rsvp_in!(event)
    if event.full?
      return flash[:notice] = "The event is currently full."
    else
      if @existing_rsvp = event.rsvps.find(guest_id: self.id).present?
        @existing_rsvp.destroy
      end
      rsvps.create!(plan_id: event.id, inout: 1)
    end
  end

  def rsvp_out!(event)
    if event.guest_count == event.min #not letting it untip anymore
      #Warning: this will un-tip the event for everyone, are you sure?
    end
    rsvps.find_by_plan_id(event.id).first.inout = 0
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
      other_user.delay.contact_confirm(self)
    else
      unless self.following?(other_user) || self.request_following?(other_user)
        self.follow!(other_user)
      end
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      @relationship.confirmed = true
      @relationship.save
      other_user.delay.contact_friend(self)
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
        unless self.invited?(r.plan) || r.plan.starts_at.blank? || r.plan.starts_at < (Time.now - 3.days)
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
    if self.in?(event)
      if self.rsvps.find_by_plan_id(event.id).invite_all_friends?
        return true
      end
    end
    return false
  end
  
  def invite_all_friends!(event)
    self.followers.each do |f|
      unless f.invited?(event) || f.rsvpd?(event)
        #silo by city, so that invite all only does relevant friends
        if f.city == self.city
          self.invite!(event, f)
        end
      end
    end
    if self.in?(event)
      r = self.rsvps.find_by_plan_id(event.id)
      r.invite_all_friends = true
      r.save
    end
  end

  def invite!(event, other_user)
    unless other_user.invited?(event)
      other_user.invitations.create!(invited_event_id: event.id, inviter_id: self.id)
      other_user.new_invited_events_count += 1
      other_user.save
    end
  end

  def forecast(load_datetime)
    Time.zone = self.city.timezone
    @forecast = []
    (-3..26).each do |i|
      @events = []
      @new_datetime = load_datetime + i.days #Date.strptime(load_date, "%Y-%m-%d") + i
      @events_on_date = self.events_on_date(@new_datetime)
      @events_on_date = @events_on_date.sort_by{|t| t[:starts_at]}
      @events_on_date.each do |e|
        @events.push(e)
      end
      @forecast.push(@events)
    end
    return @forecast
  end

  def events_on_date(load_datetime)
    Time.zone = self.city.timezone
    @time_range = load_datetime.midnight .. load_datetime.midnight + 1.day - 1.second
    #CATEGORY TODO
    @toggled_category_ids = []
    self.categories.each do |tcat|
      @toggled_category_ids.push(tcat.id)
    end

    # loop through categories and add all relevant events from city + category
    @interest_events_on_date = Event.where(starts_at: @time_range, is_public: true, city_id: self.city.id)
      .joins(:categorizations).where(categorizations: {category_id: @toggled_category_ids} ).order("starts_at ASC")

    @interest_events_on_date.each do |inte|
      inte.inviter_id = inte.user.id
    end

    @plans_on_date = Event.where(starts_at: @time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: self.id}).order("starts_at ASC")
    
    @plans_on_date.each do |p|
      p.inviter_id = p.user.id
    end
    @invited_events_on_date = Event.where(starts_at: @time_range).joins(:invitations)
                              .where(invitations: {invited_user_id: self.id}).order("starts_at ASC")
    @invited_events_on_date = @invited_events_on_date - @plans_on_date
    @invited_events_on_date.each do |ie|
      ie.inviter_id = ie.invitations.find_by_invited_user_id(self.id).inviter_id
    end
    Time.zone = self.city.timezone
    return @invited_events_on_date | @plans_on_date | @interest_events_on_date
  end

  def mobile_events_on_date(load_datetime)#don't care about toggled here, do it locally on client

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

  # Contact methods
  def contact_invitation(event, inviter)
    @event = event
    @inviter = inviter
    if self.iPhone_user?
      d = APN::Device.find_by_id(self.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@inviter.name} .invited you to: #{@event.title}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:type => "invitation", :event => "#{@event.id}"}
        n.save
      end
    elsif self.android_user?
      d = Gcm::Device.find_by_id(self.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@inviter.name} .invited you to: #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{@event.user.name} Shared an idea"}}
        n.save
      end
    else
      Notifier.invitation(@event, self, @inviter)
    end
  end

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
          n.custom_properties = {:type => "reminder", :event => "#{@event.id}"}
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
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{@event.short_event_title} starts soon"}}
        n.save
      end
    else
      unless @user == User.find_by_email("info@hoos.in")
        Notifier.rsvp_reminder(@event, @user)
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
      Notifier.new_time(event, @user)
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
        n.alert = "#{@event.title} changed time to #{@event.start_time}!"
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
        n.collapse_key = "#{@event.title} changed time to #{@event.start_time}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{event.title} changed time!"}}
        n.save
      end
    else
      Notifier.time_change(event, @user)
    end
  end

  def contact_comment(event, comment)
    @commenter = comment.user.name
    @event = event
    @comment = comment
    @comments = event.comments.order('created_at DESC').limit(4)
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
        n.custom_properties = {:type => "new_comment", :event => "#{@event.id}"}
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
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "New Comment - #{@event.short_event_title}"}}
        n.save
      end
    else
      @comment_time = comment.created_at.strftime "%l:%M%P, %A %B %e"
      @event_link = event_url(@event)
      Notifier.email_comment(event, comment, @user)
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
        n.alert = "Cancellation - #{@event.event_day}, #{@event.title}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:type => "cancel", :event => "#{@event.id}"}
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
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "Cancellation - #{@event.event_day}, #{@event.title}"}}
        n.save
      end
    else 
      unless @user == @event.user
        Notifier.cancellation(@event, @user)
      end
    end
    @event.destroy
  end

  def contact_tipped(event)
    @event = event
    @user = self
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.title} Tipped!"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:type => "tipped", :event => "#{@event.id}"}
        n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.title} Tipped!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{@event.title} Tipped!"}}
        n.save
      end
    else
      Notifier.event_tipped(@event, @user)
    end
  end

  def contact_deadline(event)
    @event = event
    @user = self
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.title} has not tipped!"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:type => "deadline", :event => "#{@event.id}"}
        n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.title} has not yet tipped!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "#{@event.title} has not tipped!"}}
        n.save
      end
    else
      Notifier.event_deadline(@event)
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
        n.custom_properties = {:type => "new_friend", :friend => "#{@follower}"}
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
        n.data = {:registration_ids => [d.registration_id], :data => {:message_text => "New Friend - #{@follower.name}"}}
        n.save
      end
    else
      #@follower_pic = raster_profile_picture(@user)
      Notifier.new_friend(@user, @follower)
    end
  end

  def contact_confirm(friend)
    @user = user
    @follower = friend
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Confirm Friend - #{@follower.name}"
        n.badge = 1
        n.sound = true
        n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Confirm Friend - #{@follower.name}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMtoken], :data => {:message_text => "Confirm Friend - #{@follower.name}"}}
        n.save
      end
    else
      Notifier.confirm_friend(@user, @follower)
    end
  end

  # Class Methods
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
            @events = u.events_on_date(@date)
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
                @events = u.events_on_date(@date)
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
