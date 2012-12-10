class Category < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user

  has_many :events, :through => :interests
  has_many :users, through: :interests
  
end
