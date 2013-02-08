class Relationship < ActiveRecord::Base
  attr_accessible :followed_id, :followed_id

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :status, presence: true

	def toggle!
		self.toggled = !self.toggled
	end

	def confirm!
		self.confirmed = true
	end

	def confirmed?
		self.confirmed
	end
end
