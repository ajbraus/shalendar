class EmailInvite < ActiveRecord::Base
  belongs_to :event
  attr_accessible :email, :id, :inviter_id

  validates :email, presence: true
  validates :email, uniqueness: { scope: :event_id, message: "They're already invited"}

  def as_json(options = {})
    {
      :eid => self.event_id,
      :uid => self.inviter_id
    }
  end

end
