class Out < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  belongs_to :user
  belongs_to :outable, polymorphic: true

  validates :user_id, presence: true
  validates :event_id, presence: true
end