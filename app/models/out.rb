class Out < ActiveRecord::Base
  attr_accessible :outable_id, :flake_id

  belongs_to :flake
  belongs_to :outable, polymorphic: true

  validates :user_id, presence: true
  validates :event_id, presence: true
end