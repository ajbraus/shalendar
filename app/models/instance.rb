class Instance < ActiveRecord::Base
  attr_accessible :duration, :over, :starts_at, :ends_at, :chronic_starts_at
  validates :duration, :starts_at, presence: true

  belongs_to :event
  belongs_to :city
  
  has_many :rsvps, as: :rsvpable
  has_many :guests, through: :rsvps, source: :guest

  has_many :invites, as: :inviteable, dependent: :destroy
  has_many :invited_users, through: :invites, source: :invitee, class_name: "User"

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

  def friends_in(current_user)
    self.guests & current_user.friends
  end

  def inmates_in(current_user)
    self.guests & current_user.inmates
  end

  def friends_in_count(current_user)
    (self.guests & current_user.friends).count
  end

  def inmates_in_count(current_user)
    (self.guests & current_user.inmates).count
  end

  def friends_and_inmates_in(current_user)
    (self.guests & current_user.intros_and_friends)
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

  def self.remove_overs
    Invitation.all.each do |i|
      Time.zone = i.user.city.timezone
      if i.event.one_time? && i.ends_at > Time.zone.now
        i.destroy
      end
    end
  end
end
