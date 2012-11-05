require 'chronic'
require 'icalendar'

class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :suggestion

  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps

  has_many :invitations, foreign_key: "invited_event_id", dependent: :destroy
  has_many :invited_users, through: :invitations

  has_many :comments, dependent: :destroy
  has_many :email_invites, dependent: :destroy
  has_many :fb_invites, dependent: :destroy

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
                  :promo_url

  has_attached_file :promo_img, :styles => { :original => '900x700',
                                             :large => '380x520',
                                             :medium => '190x270'},
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "event/:attachment/:style/:id.:extension"
                             #:default_url => "https://s3.amazonaws.com/hoosin-production/event/promo_img/medium/default_promo_img.png"

  validates :promo_img, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] }
                     #:attachment_size => { :in => 0..500.kilobytes }

  validates :user_id,
            :title,
            :starts_at,
            :chronic_starts_at,
            :duration, 
            :ends_at, presence: true
  validates :max, numericality: { in: 1..1000000, only_integer: true }, allow_blank: true
  validates :min, numericality: { in: 1..1000000, only_integer: true }, allow_blank: true
  validates :duration, numericality: { in: 0..1000 } 
  validates :title, length: { maximum: 140 }
  validates_numericality_of :longitude, :latitude, allow_blank:true
  #@url = /^((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?)?$/ 
  #validates :link, :format => { :with => @url }, allow_blank:true
  #@img_url = /^((https?:\/\/)?.*\.*\.*\.(?:png|jpg|jpeg|gif))$/i
  #validates :promo_url, :format => { :with => @img_url }, allow_blank:true
  @youtube_url = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?(\w{10,})/
  validates :promo_vid, :format => { :with => @youtube_url }, allow_blank:true
  validates :price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}, allow_blank:true

 
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
    self.starts_at.strftime "%l:%M%P, %A %B %e"
  end

  def start_date
    self.starts_at.strftime "%A, %B %e"
  end

  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def tip!
    if self.tipped? == false
      self.guests.each do |g|
        Notifier.delay.event_tipped(self, g)
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

  def has_promo_img
    if self.promo_img.url(:medium) == "/promo_imgs/medium/missing.png"
      return false
    else
      return true
    end
  end

  def post_to_fb_wall(uid, graph)
    if Rails.env.production?
      if self.has_promo_img
        graph.delay.put_connections( uid, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}",
                                        :picture => self.promo_img.url(:medium)
                                      })
      else
        graph.delay.put_connections( uid, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}"
                                      })       
      end
    else
      if self.has_promo_img
        graph.put_connections( 2232003, "feed", {
                                        :name => self.title,
                                        :link => "http://www.hoos.in/events/#{self.id}",
                                        :picture => self.promo_img.url(:medium)
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

  def nice_price
    if price
      "$" + "%.2f" % price
    end
  end

# END OF CLASS
end

