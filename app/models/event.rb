require 'chronic'
require 'icalendar'

class Event < ActiveRecord::Base
  default_scope where(:dead=>'f')

  belongs_to :user
  belongs_to :city

  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps, :conditions => ['inout = ?', 1]

  has_many :comments, dependent: :destroy
  has_many :email_invites, dependent: :destroy

  belongs_to :parent, :foreign_key => "parent_id", :class_name => "Event"
  has_many :instances, :foreign_key => "parent_id", :class_name => "Event"

  attr_accessible :user_id,
                  :starts_at, 
                  :duration,
                  :ends_at,
                  :title, 
                  :description,
                  :address, 
                  :latitude,
                  :longitude,
                  :chronic_starts_at,
                  :link,
                  :gmaps,
                  :price,
                  :promo_img,
                  :promo_vid,
                  :promo_url,
                  :family_friendly,
                  :short_url,
                  :parent_id,
                  :require_payment,
                  :slug,
                  :city_id,
                  :one_time,
                  :dead,
                  :visibility,
                  :fb_id

  has_attached_file :promo_img, :styles => { :large => '380x520',
                                             :medium => '190x270'},
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "event/:attachment/:style/:id.:extension"
                             #:default_url => "https://s3.amazonaws.com/hoosin-production/event/promo_img/medium/default_promo_img.png"

  validates :promo_img, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] }
                     #:attachment_size => { :in => 0..500.kilobytes }

  validates :city_id, presence: true if Rails.env.production?
  validates :user_id,
            :title, presence: true
  validates :duration, numericality: { in: 0..1000 }, allow_blank: true 
  validates :title, length: { maximum: 140 }
  validates_numericality_of :longitude, :latitude, allow_blank:true
  validates :price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}, allow_blank:true
  
  #@youtube_url = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?(\w{10,})/
  #validates :promo_vid, :format => { :with => @youtube_url }, allow_blank:true
  
  #@url = /^((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?)?$/ 
  #validates :link, :format => { :with => @url }, allow_blank:true
  
  #@img_url = /^((https?:\/\/)?.*\.*\.*\.(?:png|jpg|jpeg|gif))$/i
  #validates :promo_url, :format => { :with => @img_url }, allow_blank:true
  
  extend FriendlyId
  friendly_id :title, use: :slugged  

  def should_generate_new_friendly_id?
    self.new_record? || self.slug.blank?
  end


  def as_json(options = {})
    {
      :eid => self.id,
      :title => self.title,
      :start => starts_at,
      :end => ends_at,
      :host => self.user,
      :gcnt => self.guest_count,
      :guests => self.guests    
    }
  end

  def url_starts_at
    self.starts_at.utc.strftime "%Y%m%d" + "T" + "%H%M%S" + "Z"
  end 

  def url_ends_at
    self.ends_at.utc.strftime "%Y%m%d" + "T" + "%H%M%S" + "Z"
  end

  def start_time
    if starts_at.present?
      self.starts_at.strftime "%A %B %e, %l:%M%P"
    else
      "TBD"
    end
  end

  def start_date_time
    if self.starts_at.present?
      self.starts_at.strftime "%A %B %e, %l:%M%P"
    else
      "TBD"
    end
  end

  def start_time_no_date
    if self.starts_at.present?
      self.starts_at.strftime "%l:%M%P"
    else
      "TBD"
    end
  end

  def mini_start_date_time
    if starts_at.present?
      self.starts_at.strftime "%a %-m/%e, %l:%M%P"
    else
      "TBD"
    end
  end
  
  def mini_start_time
    if starts_at.present?
      self.starts_at.strftime "%l:%M%P"
    else
      "TBD"
    end
  end
  
  def start_date
    if starts_at.present?
      self.starts_at.strftime "%A, %B %e"
    else
      "TBD"
    end
  end

  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def chronic_starts_at
    self.starts_at
  end

  def chronic_starts_at=(s)
    Chronic.time_class = Time.zone
    self.starts_at = Chronic.parse(s) if s
  end

  def event_day
    if self.starts_at.present?
      self.starts_at.strftime "%A"
    end
  end

  def short_event_title
    if self.title.size >=20
      self.title.slice(0..20) + "..."
    else
      self.title
    end
  end

  def friends_in(current_user)
    self.guests.select { |g| current_user.is_friends_with?(g) }
  end

  def inmates_in(current_user)
    self.guests.select { |g| current_user.is_inmates_with?(g) }
  end

  def friends_in_count(current_user)
    self.guests.select { |g| current_user.is_friends_with?(g) }.count
  end

  def inmates_in_count(current_user)
    self.guests.select { |g| current_user.is_inmates_with?(g) }.count
  end

  def friends_and_inmates_in(current_user)
    self.guests.select { |g| current_user.is_inmates_or_friends_with?(g) }
  end

  def friends_invited_count(current_user)
    @invited_friends = []
    self.maybes.each do |u|
      if current_user.is_friends_with?(u) && !u.rsvpd?(self)
        @invited_friends.push(u)
      end
    end
    return @invited_friends.count
  end

  def maybes
    self.guests.each do |g|
      @g_maybes = []
      (g.inmates | g.friends).each do |person|
        unless person.rsvpd?(self)
          @g_maybes.push(person) 
        end
      end
      @maybes = @maybes | @g_maybes
    end
  end

  def has_image?
    if self.parent.present?
      if self.parent.promo_url.present?
        return true
      elsif self.parent.promo_img.url(:medium) != "/promo_imgs/medium/missing.png"
        return true
      end
    else
      if self.promo_url.present?
        return true
      elsif self.promo_img.url(:medium) != "/promo_imgs/medium/missing.png"
        return true
      end
    end
    return false
  end

  def post_to_fb_wall(uid, graph)
    if Rails.env.production?
      if self.has_image?
        graph.delay.put_connections( uid, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}",
                                        :picture => self.image(:medium)
                                      })
      else
        graph.delay.put_connections( uid, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}"
                                      })       
      end
    else
      if self.has_image?
        graph.put_connections( 2232003, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}",
                                        :picture => self.image(:medium)
                                      })
      else
        graph.put_connections( 2232003, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}"
                                      })
      end
    end
  end

  def to_ics
    @ics_event = Icalendar::Event.new
    @ics_event.start = self.starts_at.strftime("%Y%m%dT%H%M%S")
    @ics_event.end = self.ends_at.strftime("%Y%m%dT%H%M%S")
    @ics_event.summary = self.title
    @ics_event.description = self.description
    @ics_event.location = self.address if self.address
    @ics_event.klass = "PUBLIC"
    @ics_event.created = self.created_at
    @ics_event.last_modified = self.updated_at
    @ics_event.uid = @ics_event.url = "http://www.hoos.in/ideas/" + self.slug
    #@ics_event.add_comment("AF83 - Shake your digital, we do WowWare")
    return @ics_event
  end

  def image(size)
    if self.parent.present?    
      if self.parent.promo_img_file_size.present?
        if size == "medium"
          self.parent.promo_img.url(:medium)
        else
          self.parent.promo_img.url(:large)
        end
      elsif self.parent.promo_url.present?
        self.parent.promo_url
      end
    else
      if self.promo_img_file_size.present?
        if size == "medium"
          self.promo_img.url(:medium)
        else
          self.promo_img.url(:large)
        end
      elsif self.promo_url.present?
        self.promo_url
      end
    end
  end

  def nice_price
    if self.price
      "$" + "%.2f" % price
    end
  end

  def nice_duration
    self.duration.to_s.split(/\.0/)[0] + ' ' + 'hrs' if duration
  end

  def url_safe_description
    if self.description.present?
      if self.description.size >=150
        self.description.slice(0..150).gsub(/\n/," ") + "..."
      else
        self.description.gsub(/\n/," ")
      end
    else
      return ''
    end
  end

  def picture_from_url(url)
    if url.present?
      self.promo_img = open(url)
    end
  end

  def event_parent
    if self.has_parent?
      return self.parent
    end
    return self
  end

  def has_parent?
    return self.parent.present?
  end

  def is_parent?
    return self.instances.any?
  end

  def no_relevant_instances?
    @instances = self.instances
    if @instances.present? && self.one_time
      @instances.each do |i|
        if i.ends_at < Time.zone.now #ALL ENDS_ATS ARE IN THE PAST
          return true
        end
      end
    end
    return false
  end

  def next_instance
    @future_instances = self.instances.where('ends_at > ?', Time.zone.now).order('ends_at ASC')
    if @future_instances.empty?
      return nil
    else
      return @future_instances.first
    end
  end

  def has_future_instance?
    return Event.where('parent_id = ? AND ends_at > ?', self.id, Time.zone.now).any?
  end

  def over?
    return self.ends_at.present? && self.ends_at < Time.zone.now
  end

  def three_days_old?
    return self.ends_at.present? && self.ends_at < Time.zone.now.midnight - 3.days
  end
  # def is_next_instance?

  #   return 'parent'.next_instance == self
  # end

  def is_parent_or_future_instance?
    return !self.over? || self.is_parent?
  end

  def save_shortened_url
    @bitly = Bitly.new("devhoosin", "R_6d6b17c2324d119af1bcc30d03e852e9")
    @url = Rails.application.routes.url_helpers.event_url(self, :host => "hoos.in")
    @b = @bitly.shorten(@url)
    self.short_url = @b.short_url
    self.save
  end
  
  def unrsvpd_users
    @unrsvps = self.rsvps.where(inout: 0) #USERS WHO ARE IN
    if @unrsvps.any?
      @unrsvpd_users = @unrsvps.map { |r| User.find_by_id(r.guest_id) }
      return @unrsvpd_users
    else
      return []
    end    
  end

  def guest_count
    return self.rsvps.where(inout: 1).count
  end

  def outs
    @rsvps = self.rsvps.where(inout: 0)
    @outs = @rsvps.map { |r| r.guest }
  end

  def public?
    return self.visibility == 3
  end

  def open_invite?
    return self.visibility == 2
  end

  def friends_only?
    return self.visibility == 1
  end

  def invite_only?
    return self.visibility == 0
  end

  def visibility_icon 
    if self.public?
      return "- <i class='icon-bullhorn'></i>"
    elsif self.friends_only?
      return "- <i class='icon-star friend_star'></i>"
    elsif self.invite_only?
      return "- <i class='icon-eye-close'></i>"
    end
  end

# END OF CLASS
end

