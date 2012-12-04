class Category < ActiveRecord::Base
  attr_accessible :name

  belongs_to :event

  has_many :categories, :through => :interests
  has_many :users, through: :interests
  
end
