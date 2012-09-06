require 'chronic'

class Event < ActiveRecord::Base
  acts_as_gmappable :validation => false
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps
  has_many :invites, dependent: :destroy
  attr_accessible :id,
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
                  :visibility,
                  :link,
                  :gmaps

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
  
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def tip!
    if self.tipped? == false
      self.tipped = true
      Notifier.event_tipped(self).deliver
    end
  end

  def full?
    self.guests.count >= self.max
  end

  def chronic_starts_at
    self.starts_at
  end

  def chronic_starts_at=(s)
    self.starts_at = Chronic.parse(s) if s
  end

  def chronic_ends_at
    self.ends_at
  end

  def chronic_ends_at=(e)
    self.ends_at = Chronic.parse(e) if e
  end

  def ends_at
    if self.duration && self.starts_at
      self.ends_at = self.starts_at + self.duration*3600
    end
  end

  def check_tip_deadlines
    #want to change this to be for each event, check the deadline, if it's in the window then act
    @window_floor = Time.now + 1.hour + 44.minutes
    @window_ceiling = Time.now + 2.hours
    @relevant_events = Event.where(':window_floor <= events.starts_at AND 
                        events.starts_at < :window_ceiling',
                        window_floor: @window_floor, window_ceiling: @window_ceiling)
    @relevant_events.each do |re|

      if re.tipped?
        Notifier.rsvp_reminder(re).deliver
      else
        Notifier.tip_or_destroy(re).deliver
      end
    end
  end

  def gmaps4rails_address
    address
  end

  def start_time
    starts_at.strftime "%l:%M%P, %A %B %e"
  end

end

