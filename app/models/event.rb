class Event < ActiveRecord::Base
  belongs_to :user

  attr_accessible :description, :end_datetime, :location, :start_datetime, :title
  validates :user_id, presence: true

end
