require 'chronic'

class Event < ActiveRecord::Base
  acts_as_gmappable :validation => false
  belongs_to :user

  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps

  has_many :invitations, foreign_key: "invited_event_id", dependent: :destroy
  has_many :invited_users, through: :invitations

  has_many :comments, dependent: :destroy
  has_many :email_invites, dependent: :destroy

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
                  :guests_can_invite_friends

  validates :user_id,
            :title,
            :starts_at,
            :chronic_starts_at,
            :duration, presence: true
  validates :max, numericality: { in: 1..10000, only_integer: true }
  validates :min, numericality: { in: 1..10000, only_integer: true }
  # validates :duration, numericality: { in: 0..1000 } 
  validates :title, length: { maximum: 140 }
  # validates_numericality_of :lng, :lat
  @url = /^((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?)?$/ 
  validates :link, :format => { :with => @url }
 
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
        Notifier.event_tipped(self, g).deliver
      end
    end
    self.tipped = true
    self.save!
  end

  def full?
    self.guests.count >= self.max
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
    if self.duration && self.starts_at
      self.ends_at = self.starts_at + self.duration*3600
    end
  end

  def self.check_tip_deadlines
    #want to change this to be for each event, check the deadline, if it's in the window then act
    @tip_window_floor = Time.now + 2.hours + 50.minutes
    @tip_window_ceiling = Time.now + 3.hours
    @relevant_events = Event.where(':window_floor <= events.starts_at AND 
                        events.starts_at < :window_ceiling',
                        window_floor: @tip_window_floor, window_ceiling: @tip_window_ceiling)
    @relevant_events.each do |re|
      if re.tipped?
        re.guests.each do |g|
          Notifier.rsvp_reminder(re, g).deliver
        end
      else
        Notifier.tip_or_destroy(re).deliver
      end
    end

  end

  def self.clean_up
    #prune db of old events here.. for now that's anything older than 3 days ago

  end

  def gmaps4rails_address
    address
  end

  def event_day
    self.starts_at.strftime "%A"
  end
  # can't do here bc doesn't work with time zones...
  # def start_time
  #   starts_at.strftime "%l:%M%P, %A %B %e"
  # end

  def short_event_title
    if self.title.size >=50
      self.title.slice(0..50) + "..."
    else
      self.title
    end
  end
end

