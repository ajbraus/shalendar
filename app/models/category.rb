class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :categorizations
  has_many :events, through: :categorizations

  has_many :interests
  has_many :users, through: :interests
  
end
