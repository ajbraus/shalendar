require 'chronic'
require 'icalendar'

class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :city

  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps

  has_many :invitations, foreign_key: "invited_event_id", dependent: :destroy
  has_many :invited_users, through: :invitations

  has_many :comments, dependent: :destroy
  has_many :email_invites, dependent: :destroy
  has_many :fb_invites, dependent: :destroy

  belongs_to :parent, :foreign_key => "parent_id", :class_name => "Event"
  has_many :groups, :foreign_key => "parent_id", :class_name => "Event"

  has_many :categorizations, dependent: :destroy
  has_many :categories, :through => :categorizations

  attr_accessible :user_id,
                  :suggestion_id,
                  :starts_at, 
                  :duration,
                  :ends_at,
                  :title, 
                  :min, 
                  :max,
                  :address, 
                  :latitude,
                  :longitude,
                  :chronic_starts_at,
                  :chronic_ends_at,
                  :link,
                  :gmaps,
                  :tipped,
                  :guests_can_invite_friends,
                  :price,
                  :promo_img,
                  :promo_vid,
                  :promo_url,
                  :category,
                  :family_friendly,
                  :is_public,
                  :short_url,
                  :parent_id,
                  :require_payment,
                  :slug,
                  :is_big_idea

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
  validates :max, numericality: { in: 1..1000000, only_integer: true }, allow_blank: true
  validates :min, numericality: { in: 1..1000000, only_integer: true }, allow_blank: true
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
    new_record? || slug.blank?
  end


  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :start => starts_at,
      :end => ends_at,
      :host => self.user,
      :gcnt => self.guests.count,
      :tip => self.min,
      :guests => self.guests,
      :tipped => self.tipped
    }
  end

  def url_starts_at
    starts_at.utc.strftime "%Y%m%d" + "T" + "%H%M%S" + "Z"
  end 

  def url_ends_at
    ends_at.utc.strftime "%Y%m%d" + "T" + "%H%M%S" + "Z"
  end

  def start_time
    if starts_at.present?
      self.starts_at.strftime "%l:%M%P, %A %B %e"
    else
      "TBD"
    end
  end

  def start_date_time
    if starts_at.present?
      self.starts_at.strftime "%A %B %e, %l:%M%P"
    else
      "TBD"
    end
  end

  def start_time_no_date
    if starts_at.present?
      self.starts_at.strftime "%l:%M%P"
    else
      "TBD"
    end
  end

  def mini_start_date_time
    if starts_at.present?
      self.starts_at.strftime "%a, %b %e, %l:%M%P"
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

  def tip!
    if self.tipped? == false
      unless self.ends_at < Time.now
        self.guests.each do |g|
          Notifier.delay.event_tipped(self, g)
        end
      end
    end
    self.tipped = true
    self.save!
  end

  def full?
    if self.max == nil
      return false
    elsif self.guests.count >= self.max
      return true
    else 
      return false
    end
  end

  def chronic_starts_at
    self.starts_at
  end

  def chronic_starts_at=(s)
    Chronic.time_class = Time.zone
    self.starts_at = Chronic.parse(s) if s
  end

  def chronic_ends_at
    self.ends_at
  end

  def chronic_ends_at=(e)
    Chronic.time_class = Time.zone
    self.ends_at = Chronic.parse(e) if e
  end

  def ends_at
    if duration && starts_at
      ends_at = starts_at + duration*3600
    end
  end

  def self.public_forecast(load_datetime, city, toggled_categories)
    @public_forecast = []
    (-3..26).each do |i|
      @new_datetime = load_datetime + i.days 
      @time_range = @new_datetime.midnight .. @new_datetime.midnight + 1.day
      
      @public_events_on_date = Event.where(starts_at: @time_range, is_public: true, city_id: city.id).order("starts_at ASC") #.joins(:categories).where(categories: {id: toggled_categories} )
      
      #Previous stuff while this included a signed in user
      #   if current_user.family_filter?
      #     @public_events_on_date = Event.where(starts_at: @time_range, is_public: true, family_friendly: true).order("starts_at ASC").reject { |e| current_user.rsvpd?(e) || current_user.invited?(e) || current_user.invited_to_an_events_group?(e)}
      #   else 
      #     @public_events_on_date = Event.where(starts_at: @time_range, is_public: true).order("starts_at ASC").reject { |e| current_user.rsvpd?(e) || current_user.invited?(e) || current_user.invited_to_an_events_group?(e) || current_user.made_a_group?(e) }
      #   end
      # @public_events_on_date = @public_events_on_date.sort_by{|t| t[:starts_at]}

      @public_forecast.push(@public_events_on_date)
    end
    return @public_forecast
  end

  def self.check_tip_deadlines
    #want to change this to be for each event, check the deadline, if it's in the window then act
    # @tip_window_floor = Time.now + 1.hour + 50.minutes
    # @tip_window_ceiling = Time.now + 2.hours
    # @relevant_events = Event.where(':window_floor <= events.starts_at AND 
    #                     events.starts_at < :window_ceiling',
    #                     window_floor: @tip_window_floor, window_ceiling: @tip_window_ceiling)
    time_range = Time.now + 1.hour + 50.minutes .. Time.now + 2.hours
    Event.where(starts_at: time_range).each do |re|
      if re.tipped?
        re.guests.each do |g|
          Notifier.delay.rsvp_reminder(re, g)
        end
      else
        Notifier.delay.tip_or_destroy(re)
      end
    end
  end

  def self.clean_up
    #prune db of old events here.. for now that's anything older than 3 days ago

  end

  def event_day
    self.starts_at.strftime "%A"
  end

  def short_event_title
    if self.title.size >=50
      self.title.slice(0..50) + "..."
    else
      self.title
    end
  end

  def has_image?
    if self.parent.nil?
      if self.promo_img.url(:medium) == "/promo_imgs/medium/missing.png"  && self.promo_url.blank?
        return false
      else
        return true
      end
    else
      if self.parent.promo_img.url(:medium) == "/promo_imgs/medium/missing.png"  && self.parent.promo_url.blank?
        return false
      else
        return true
      end
    end
  end

  def image(size)
    if self.parent.nil?
      if !self.promo_url.blank?
        return promo_url
      elsif !self.promo_img_file_size.nil?
        if size == :medium
          return self.promo_img.url(:medium)
        else 
          return self.promo_img.url(:large)
        end
      else
        return nil
      end
    else
      if !self.parent.promo_url.blank?
        return parent.promo_url
      elsif !self.parent.promo_img_file_size.nil?
        if size == :medium
          return self.parent.promo_img.url(:medium)
        else 
          return self.parent.promo_img.url(:large)
        end
      else 
        return nil
      end
    end
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
    #@event.description = self.description
    @ics_event.location = self.address if self.address
    @ics_event.klass = "PUBLIC"
    @ics_event.created = self.created_at
    @ics_event.last_modified = self.updated_at
    @ics_event.uid = @ics_event.url = "http://www.hoos.in/events/#{self.id}"
    #@ics_event.add_comment("AF83 - Shake your digital, we do WowWare")
    @ics_event
  end

  def image(size)
    if !self.promo_url.nil? && self.promo_url != ""
      self.promo_url
    elsif !self.promo_img_file_size.nil?
      if size == "medium"
        self.promo_img.url(:medium)
      else
        self.promo_img.url(:large)
      end
    end
  end

  def nice_price
    if price
      "$" + "%.2f" % price
    end
  end

  def nice_duration
    duration.to_s.split(/\.0/)[0]
  end

  def is_group?
    unless self.parent.nil?
      if self.parent.is_public?
        return true
      end
    end
    return false
  end

  def groups_your_invited_to
    @invited_events = []
    if self.is_public? && self.groups.any?
      self.groups.each do |group|
        group.invited_users.each do |iu|
          if iu == current_user
            @invited_event << group
          end
        end
      end
    end
    return @invited_events
  end

  def has_parent?
    if self.parent.nil?
      return false
    else
      return true
    end
  end

  def save_shortened_url
    @bitly = Bitly.new("devhoosin", "R_6d6b17c2324d119af1bcc30d03e852e9")
    @url = Rails.application.routes.url_helpers.idea_url(self, :host => "hoos.in")
    @b = @bitly.shorten(@url)
    self.short_url = @b.short_url
    self.save
  end

  def total_guests
    if self.groups.any?
      @event_group_guests_count = 0
      self.groups.each do |g|
        @guests_count = g.guests.count 
          @event_group_guests_count += @guests_count
      end
      @total = self.guests.count + @event_group_guests_count
    else
      @total = self.guests.count 
    end
    return @total 
  end

# END OF CLASS
end

