class InstanceOut < ActiveRecord::Base
  attr_accessible :instance_id, :user_id

  belongs_to :user
  belongs_to :event

  validates :user_id, presence: true
  validates :instance_id, presence: true
end