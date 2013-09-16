class Invite < ActiveRecord::Base
  attr_accessible :event_id, :invitee_id, :inviter_id, :friends_in, :intros_in, :randos_in

  belongs_to :inviteable, polymorphic: true
  belongs_to :invitee, class_name: "User"
  belongs_to :inviter, class_name: "User"

  validates :invitee_id, presence: true
  validates :inviteable_id, presence: true
  validates :inviteable_type, presence: true
  validates :inviter_id, presence: true
end