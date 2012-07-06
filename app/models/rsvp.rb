class Rsvp < ActiveRecord::Base
  attr_accessible :plan_id

  belongs_to :guest, class_name: "User"
  belongs_to :plan, class_name: "Event"

  validates :guest_id, presence: true
  validates :plan_id, presence: true
end
