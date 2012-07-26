class Invitation < ActiveRecord::Base
  attr_accessible :pending_plan_id, :invited_user_id

  belongs_to :invited_user, class_name: "User"
  belongs_to :pending_plan, class_name: "Event"

  validates :invited_user_id, presence: true
  validates :pending_plan_id, presence: true
end
