class EmailInvite < ActiveRecord::Base
  belongs_to :event
  attr_accessible :email, :id, :inviter_id

  validates :email, presence: true
  validates :email, uniqueness: { scope: :event_id, message: "They're already invited"},
  								 format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  def as_json(options = {})
    {
      :eid => self.event_id,
      :uid => self.inviter_id
    }
  end

end
