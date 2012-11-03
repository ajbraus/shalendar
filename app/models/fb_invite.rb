class FbInvite < ActiveRecord::Base
  belongs_to :event
  attr_accessible :uid, :inviter_id, :fb_pic_url, :name

  validates :uid, :inviter_id, :fb_pic_url, presence: true
  #validates :fb_uid, uniqueness: { scope: :event_id, message: "They're already invited"}

  def as_json(options = {})
    {
      :eid => self.event_id,
      :uid => self.inviter_id
    }
  end
end
