class Event < ActiveRecord::Base
  belongs_to :user
  has_many :rsvps, foreign_key: "plan_id", dependent: :destroy
  has_many :guests, through: :rsvps

  attr_accessible :description, :ends_at, :location, :starts_at, :title
  validates :user_id, presence: true


  #scope :maybes, lambda {|guest| joins('rsvps').on('plan_id').where("guest_id != ?", guest)

  #from bokmann fullcalendar event model
  scope :before, lambda {|end_time| {:conditions => ["ends_at < ?", Event.format_date(end_time)] }}
  scope :after, lambda {|start_time| {:conditions => ["starts_at > ?", Event.format_date(start_time)] }}
  
  # scope :not_my_plans, {|event| {:conditions => ["current_user NOT IN ?", ]}}
  # scope :not_my_plans, lambda {|user| where(" ? NOT IN guest_id", user.id)}
  # scope :not_my_plans, Event.where("guest_id != ?", params[:user.id] )
  # scope :not_my_events, Event.where("user != ?", )
  
  # scope :my_plans where(user: current_user).joins('rsvps').on('rsvps.guest_id = user_id').joins('users').on('rsvps.guest_id = user.id')}
  # scope :my_maybes where(user: current_user).joins('rsvps').on('rsvps.guest_id != user_id')}
  # scope :my_events current_user.events

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

end

