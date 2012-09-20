class Invitation < ActiveRecord::Base
  attr_accessible :invited_user_id,
  								:invited_event_id,
  								:inviter_id

  belongs_to :invited_user, class_name: "User"
  belongs_to :inviter, class_name: "User"
  belongs_to :invited_event, class_name: "Event"

  validates :invited_user_id, presence: true
  validates :invited_event_id, presence: true
  validates :inviter_id, presence: true

end

