class Invite < ActiveRecord::Base
  belongs_to :event
  attr_accessible :email

  validates :email, presence: true
  validates :email, uniqueness: { scope: :event_id, message: "They're already invited"},
  								 format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }
end
