class Out < ActiveRecord::Base
  attr_accessible :outable_id, :flake_id

  belongs_to :flake, class_name: "User"
  belongs_to :outable, polymorphic: true

  validates :user_id, presence: true
  validates :outable_id, presence: true
end