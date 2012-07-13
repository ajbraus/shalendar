require 'chronic'
class Event < ActiveRecord::Base
  belongs_to :user
  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps

  attr_accessible :description, 
                  :ends_at, 
                  :location, 
                  :starts_at, 
                  :title, 
                  :min, 
                  :max, 
                  :map_location,
                  :chronic_starts_at,
                  :chronic_ends_at


  validates :user_id,
            :title,
            :starts_at,
            :ends_at, presence: true

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
      :description => self.description || "",
      :start => starts_at.rfc822,
      :end => ends_at.rfc822,
      :allDay => false, #self.all_day,
      :recurring => false,
      :url => Rails.application.routes.url_helpers.event_path(id)
    }
    
  end
  
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def tipped?
    self.guests.count >= self.min
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

end

