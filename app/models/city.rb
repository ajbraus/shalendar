class City < ActiveRecord::Base
  attr_accessible :name, :timezone

  has_many :users
  has_many :events
  
end
