class Invitation < ActiveRecord::Base
  attr_accessible :event_id, :user_id, :inviter_id, :friends_in, :intros_in, :randos_in

  belongs_to :user
  belongs_to :invitationable, polymorphic: true
  
  belongs_to :inviter, class_name: "User"

  validates :user_id, presence: true
  validates :event_id, presence: true
  validates :inviter_id, presence: true
end