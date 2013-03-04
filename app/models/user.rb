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
  
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  
  has_many :friended_bys, :through => :reverse_relationships, :source => :follower, conditions: "status = 2"

  has_many :inmates, through: :relationships, source: :followed, conditions: "status = 1"  
  has_many :friends, through: :relationships, source: :followed, conditions: "status = 2"  

  has_many :inmates_and_friends, through: :relationships, source: :followed

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
   {
    :uid => self.id,
    :first_name => self.first_name,
    :last_name => self.last_name,
    :pic_url => @pic_url,
    :in_cnt => self.plans.count,
    :f_cnt => self.friends.count + self.inmates.count
    #:email_hex => Digest::MD5::hexdigest(self.email.downcase)
    #:profile_pic_url => "https://secure.gravatar.com/avatar/#{Digest::MD5::hexdigest(user.email.downcase)}?s=50"
    }
  end

  def nice_name
    @name_array = self.name.split(' ')
    @name_array.each { |n| n.capitalize }
  end

  def first_name
    @name_array = self.name.split(' ')
    @name_array[0].capitalize
  end

  def first_name_with_last_initial
    @name_array = self.name.split(' ')
    @name_array[0].capitalize + " " + @name_array.last.capitalize.slice(0) + "."
  end

  def last_name
    @name_array = self.name.split(' ')
    @name_array.last
  end

  def middle_name
    self.name.split.count > 3 ? self.name.split(' ')[1] : nil
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
    return false
  end

  def flake_out!(event)
    if event.rsvps.where(guest_id: self.id).any?
      @existing_rsvp = event.rsvps.where(guest_id: self.id).first
      @existing_rsvp.destroy
      # if(event.has_parent?) #don't want to be out, just not in
      #   self.rsvp_out!(event)
      # end
    end
  end

  #moved all parent logic into the model
  def rsvp_in!(event)
    @existing_rsvp = event.rsvps.where(guest_id: self.id).first 
    if @existing_rsvp.present?
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
    if event.parent.present? && !self.in?(event.parent)
      self.rsvp_in!(event.parent)
    else #contact only once if they sign up for time + idea 
      unless event.user == self || event.over?
        event.user.delay.contact_new_rsvp(event, self)
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
    @authentication = self.authentications.find_by_provider("Facebook")
    if @authentication.present?
      "#{@authentication.pic_url}"
    else
      if self.avatar.url.blank?
        "https://s3.amazonaws.com/hoosin-production/user/avatars/raster/default_profile_pic.png"
      else
        self.avatar.url(:raster)
      end
    end
  end 

  def ins
    @ins = []
    self.plans.each do |p|
      if p.ends_at.blank?
        @ins.push(p)
      else
        if p.ends_at > Time.zone.now && p.one_time?
          @ins.push(p)
        end
      end
    end
    return @ins
  end

  #Relationship methods
  def is_friends_with?(other_user)
    unless other_user.ignores?(self)
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      if @relationship.present? && @relationship.status == 2
        return true
      end
    end
    return false
  end

  def is_friended_by?(other_user)
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
    unless other_user.ignores?(self)
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      if @relationship.present? && @relationship.status == 1
        return true
      end
    end
    return false
  end

  def is_inmates_or_friends_with?(other_user)
    unless other_user.ignores?(self)
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      if @relationship.present?
        unless @relationship.status == 0
          return true
        end
      end
    end
    return false
  end

  #used in self.follow_up to get .in-mates created in the past day
  def is_new_inmate?(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present? && @relationship.created_at > Time.zone.now.in_time_zone(self.city.timezone).midnight - 1.day
      return true
    end
    return false
  end

  def friend!(other_user)
    unless other_user.ignores?(self)
      @reverse_relationship = other_user.relationships.find_by_followed_id(self.id)
      if @reverse_relationship.nil?
        other_user.inmate!(self)
      end
      @relationship = self.relationships.find_by_followed_id(other_user.id)
      if @relationship.present?
        @relationship.status = 2
        @relationship.save
      else 
        self.inmate!(other_user)
        self.friend!(other_user)
      end
    end
  end

  def inmate!(other_user)
    unless other_user == self || other_user.ignores?(self)
      unless self.is_inmates_or_friends_with?(other_user) || self.ignores?(other_user) || self.id == other_user.id
        self.relationships.create(followed_id: other_user.id, status: 1)
      end
      unless other_user.is_inmates_or_friends_with?(self) || self.ignores?(other_user)
        other_user.relationships.create(followed_id: self.id, status: 1)
      end
    end
  end

  def re_inmate!(other_user)
    unless other_user == self
      @relationship = Relationship.where(follower_id: other_user.id, followed_id: self.id).first
      if @relationship.blank?
        self.relationships.create(followed_id: other_user.id, status: 1)
      else
        @relationship.status = 1
        @relationship.save
      end
      @reverse_relationship = Relationship.where(follower_id: self.id, followed_id:  other_user.id).first
      if @reverse_relationship.blank?
        other_user.relationships.create(followed_id: self.id, status: 1)
      end
    end
  end

  def ignore_inmate!(inmate)
    #they don't ignore back, they just are no longer inmates
    @reverse_relationship = inmate.relationships.find_by_followed_id(self.id)
    unless @reverse_relationship.nil?
      @reverse_relationship.destroy
      # @reverse_relationship.status = 0
      # @reverse_relationship.save
    end

    @relationship = self.relationships.find_by_followed_id(inmate.id)
    unless @relationship.nil?
      @relationship.status = 0
      @relationship.save
    end
  end

  def unfriend!(other_user)
    @relationship = self.relationships.find_by_followed_id(other_user.id)
    if @relationship.present?
      @relationship.status = 1
      @relationship.save
    end
  end

  def invited?(event)
    @parent = event.parent
    if @parent.present?
      if self.in?(@parent)
        return true
      elsif @parent.friends_only?
        if @parent.user.is_friends_with?(self) || event.user.is_friends_with?(self)
          return true
        end
      end
    else
      if self.in?(event)
        return true
      elsif event.friends_only?
        return event.user.is_friends_with?(self)
      elsif (event.guests & self.inmates_and_friends).any?
        return true
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


  # Contact methods

  def contact_new_idea(event)
    @user = self
    @event = event
    @event_user = @event.user

    if @user.iPhone_user == true
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
          n = APN::Notification.new
          n.device = d
          n.alert = "new idea - #{@event.title} - by #{@event_user.first_name_with_last_initial}"
          n.badge = 1
          n.sound = false
          n.custom_properties = {:type => "new_idea", :id => "#{@event.id}", msg: ""}
          n.save
      end
    elsif(@user.android_user == true)
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "new idea - #{@event.title} - by #{@event_user.first_name_with_last_initial}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:type => "new_idea", :id => "#{@event.id}", :msg => ""}}
        n.save
      end
    end
    Notifier.new_idea(@event, @user).deliver
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
        n.alert = "reminder - #{@event.short_event_title} starts at #{@event.start_time_no_date}"
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
        n.collapse_key = "reminder - #{@event.short_event_title} starts at #{@event.start_time_no_date}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:type => "reminder", :id => "#{@event.id}", :msg => ""}}
        n.save
      end
    # else
    #   unless @user == User.find_by_email("info@hoos.in")
    #     Notifier.rsvp_reminder(@event, @user).deliver
    #   end
    end
  end

  def contact_new_time(event)
    @user = self
    @event = event
    @event_link = event_url(@event)
    @event_user = @event.user

    if @user.iPhone_user?
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event_user.first_name_with_last_initial} set a time for #{@event.title} - #{@event.start_time}!"
        n.badge = 1
        n.sound = false
        n.custom_properties = {:type => "new_time", :event => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event_user.first_name_with_last_initial} set a time for #{@event.title} - #{@event.start_time}!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {:type => "new_time", :message_text => "#{event.title} new time!"}}
        n.save
      end
    end
    Notifier.new_time(@event, @user).deliver
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
        n.sound = false
        n.custom_properties = {:msg => "time change - #{@event.short_event_title} - #{@event.start_time_no_date}", 
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
        n.data = {:registration_ids => [d.registration_id], :data => {:msg => "time change - #{@event.short_event_title} - #{@event.start_time_no_date}", 
                                                            :type => "time_change", 
                                                            :id => "#{@event.id}"}}
        n.save
      end
    end
    Notifier.time_change(@event, @user).deliver
  end

  def contact_comment(comment)
    @commenter = comment.user.first_name_with_last_initial
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
        n.alert = ".info - #{@comment.content} - #{@commenter}"
        n.badge = 1
        n.sound = false
        n.custom_properties = {msg: "from #{@commenter}", :type => "new_comment", :id => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user?
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = ".info - #{@comment.content} - #{@commenter}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {msg: "from #{@commenter}", :type => "new_comment", :id => "#{@event.id}"}}
        n.save
      end
    else
      Notifier.email_comment(@comment, @user).deliver
    end
  end

  def contact_cancellation(event)
    @event = event
    @user = self
    unless @user == @event.user
      if @user.iPhone_user?
        d = APN::Device.find_by_id(@user.apn_device_id)
        if d.nil?
          Airbrake.notify("thought we had an iphone user but can't find their device")
        else
          n = APN::Notification.new
          n.device = d
          n.alert = "cancellation - #{@event.title}"
          n.badge = 1
          n.sound = false
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
          n.collapse_key = "cancellation - #{@event.title}"
          n.delay_while_idle = true
          n.data = {:registration_ids => [d.registration_id], :data => {msg: "#{@event.short_event_title}", :type => "cancel", :id => "#{@event.id}"}}
          n.save
        end
      end
      Notifier.cancellation(@event, @user).deliver
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
        n.alert = "You were starred by #{@follower.name}"
        n.badge = 1
        n.sound = false
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
        n.collapse_key = "You were starred by #{@follower.name}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [d.registration_id], :data => {msg: "", :type => "new_friend", :id => "#{@follower.id}"}}
        n.save
      end
    end
      #@follower_pic = raster_profile_picture(@user)
    Notifier.new_friend(@user, @follower).deliver
  end

  #changed this to keep consistence with these all being contact to
  #user object that is calling the method
  def contact_new_rsvp(event, rsvp_user)
    @event = event
    @rsvping_user = rsvp_user
    @user = self
    if @user.iPhone_user == true
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "new .in - #{@rsvping_user.name} for #{@event.title}"
        n.badge = 1
        n.sound = false
        n.custom_properties = {msg: "", :type => "new_rsvp", :id => "#{@event.id}"}
        n.save
      end
    elsif @user.android_user == true
      d = Gcm::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "new .in - #{@rsvping_user.name} for #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMtoken], :data => {msg: "", :type => "new_rsvp", :id => "#{@rsvping_user.id}"}}
        n.save
      end
    else
      Notifier.new_rsvp(@event, @user, @rsvping_user).deliver
    end
  end

  # Class Methods
  def self.digest
    @digest_users = User.where("digest = ?", true)
    @digest_users.each do |u|
      @current_city = u.city
      @now_in_zone = Time.zone.now.in_time_zone(@current_city.timezone)
      @day = @now_in_zone.to_date.days_to_week_start
      if @day == 0 || @day == 4
        time_range = @now_in_zone.midnight .. @now_in_zone.midnight + 3.days
        @has_times = false
        @upcoming_times = []
        (0..2).each do |day|
          day_time_range = @now_in_zone.midnight + day.days .. @now_in_zone.midnight + (day+1).days
          @upcoming_day_times = u.plans.where(starts_at: day_time_range)
          if @upcoming_day_times.any?
            @has_times = true
          end
          @upcoming_times.push(@upcoming_day_times)
        end
        @all_new_ideas = Event.where('city_id = ? AND created_at > ? AND ends_at IS NULL', @current_city.id, @now_in_zone - 4.days).reject { |i| u.rsvpd?(i) && u.no_relevant_instances? }
        @new_inner_ideas = @all_new_ideas.select { |i| i.user.is_friended_by?(u) }
        @new_inmate_ideas = @all_new_ideas.select { |i| i.user.is_inmates_with?(u) }
        @users_new_ideas = @new_inmate_ideas + @new_inner_ideas
        if @has_times == true || @new_inner_ideas.any? || @new_inmate_ideas.any?
          Notifier.delay.digest(u, @upcoming_times, @has_times, @new_inner_ideas, @new_inmate_ideas, @users_new_ideas.count)
        end
      end
    end
  end

  def self.follow_up
    @recipients = User.where('follow_up = ?', true)
    @recipients.each do |r|
      @now_in_zone = Time.zone.now.in_time_zone(r.city.timezone)
      @fu_events = r.plans.where(starts_at: @now_in_zone.midnight - 1.day .. @now_in_zone.midnight)
      if @fu_events.any?
        @fu_events.each do |fue|
          @new_inmates = fue.guests.select { |g| g.is_new_inmate?(r) && r != g }
          if @new_inmates.any?
            Notifier.delay.follow_up(r, fue, @new_inmates)
          end
        end
      end
    end
  end

  def self.send_reminders
    @recipients = User.where('notify_event_reminders = ?', true)
    @recipients.each do |r|
      @now_in_zone = Time.zone.now.in_time_zone(r.city.timezone)
      @time_range = @now_in_zone + 1.hour..@now_in_zone + 1.hour + 10.minutes
      @reminder_events = r.plans.where(starts_at: @time_range)
      @reminder_events.each do |e|
        r.contact_reminder(e)
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



# PRIVATE METHODS

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
