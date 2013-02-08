class Relationship < ActiveRecord::Base
  attr_accessible :followed_id, :followed_id, :status

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :status, presence: true
end
