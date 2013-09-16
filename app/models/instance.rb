class Instance < ActiveRecord::Base
  attr_accessible :duration, :over, :starts_at, :ends_at, :chronic_starts_at
  validates :duration, :starts_at, presence: true

  belongs_to :event
  belongs_to :city
  
  has_many :rsvps, as: :rsvpable
  has_many :guests, through: :rsvps, source: :guest

  has_many :invites, as: :inviteable
  has_many :invitees, through: :invites, source: :invitee

  has_many :outs, as: :outable

  before_create :set_ends_at

  def chronic_starts_at
    self.starts_at 
  end

  def chronic_starts_at=(s)
    self.starts_at = Chronic.parse(s) if s
  end

  def nice_starts_at 
    starts_at.strftime "%l:%M%P, %a %b %e"
  end

  def set_ends_at
    self.ends_at = self.starts_at + duration*3600
  end

  def mini_start_date_time
    if starts_at.present?
      self.starts_at.strftime "%a %-m/%e, %l:%M%P"
    else
      "TBD"
    end
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

  def nice_duration
    if duration > 1
      self.duration.to_s.split(/\.0/)[0] + ' ' + 'hours' if duration
    else
      self.duration.to_s.split(/\.0/)[0] + ' ' + 'hour' if duration
    end
  end

  def self.remove_overs
    Invitation.all.each do |i|
      Time.zone = i.user.city.timezone
      if i.event.one_time? && i.ends_at > Time.zone.now
        i.destroy
      end
    end
  end
end
