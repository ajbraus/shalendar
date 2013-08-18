class Instance < ActiveRecord::Base
  belongs_to :event
  belongs_to :city
  
  has_many :instance_rsvps
  has_many :guests, through: :instance_rsvps, source: :user

  has_many :instance_invitations
  has_many :invited_users, through: :instance_invitations, source: :user

  attr_accessible :duration, :over, :starts_at, :ends_at, :chronic_starts_at

  validates :duration, :starts_at, presence: true

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

  def self.remove_overs
    Invitation.all.each do |i|
      Time.zone = i.user.city.timezone
      if i.event.one_time? && i.ends_at > Time.zone.now
        i.destroy
      end
    end
  end
end
