require 'chronic'

class Event < ActiveRecord::Base
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
                  :map_location,
                  :chronic_starts_at,
                  :chronic_ends_at,
                  :visibility

  validates :user_id,
            :title,
            :starts_at,
            :chronic_starts_at,
            :ends_at, 
            :duration, presence: true

  validates :max, numericality: { in: 1..10000, only_integer: true }
  validates :min, numericality: { in: 1..10000, only_integer: true }
  validates :duration, numericality: { in: 0..1000 } 

  validates :title, length: { maximum: 140 }
  validates :map_location, length: { maximum: 120 }

  #from bokmann fullcalendar event model
  scope :before, lambda {|end_time| {:conditions => ["ends_at < ?", Event.format_date(end_time)] }}
  scope :after, lambda {|start_time| {:conditions => ["starts_at > ?", Event.format_date(start_time)] }}
  
  #http://rorguide.blogspot.com/2011/02/to-pass-currentuser-object-to.html
  # scope :not_my_plans, lambda {|user| joins(:guest).where("guest_id != ?", user.id)}

  # need to override the json view to return what full_calendar is expecting.
  # http://arshaw.com/fullcalendar/docs/event_data/Event_Object/

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :start => starts_at,
      :end => ends_at,
      :host => self.user,
      :gcnt => self.guests.count,
      :tip => self.min,
      :guests => self.guests
    }
    
  end
  
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def tip!
    self.tipped = true
    Notifier.event_tipped(@event).deliver
  end
  
  def tipped?
    self.tipped
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
    @window_floor = Time.now + 1.hour + 44.minutes
    @window_ceiling = Time.now + 2.hours
    @relevant_events = Event.where(':window_floor <= events.start_time AND 
                        events.start_time < :window_ceiling',
                        window_floor: @window_floor, window_ceiling: @window_ceiling)
    @relevant_events.each do |re|

      if re.tipped?
        Notifier.rsvp_reminder(re).deliver
      else
        re.destroy
      end
    end
  end
end

