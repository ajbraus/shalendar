class Invitation < ActiveRecord::Base
  attr_accessible :invited_event_id, :invited_user_id

  belongs_to :invited_user, class_name: "User"
  belongs_to :invited_event, class_name: "Event"

  validates :invited_user_id, presence: true
  validates :invited_event_id, presence: true

  def self.expire
		@old_invites = Invitation.where('created_at > ?', Time.now - 1.week)  	
		@old_invites.each do |i|
			i.destroy
		end
  end
end