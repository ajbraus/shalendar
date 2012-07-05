class Event < ActiveRecord::Base
  belongs_to :user

  attr_accessible :description, :ends_at, :location, :starts_at, :title
  validates :user_id, presence: true

end
