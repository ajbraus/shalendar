class Interest < ActiveRecord::Base
  attr_accessible :category_id, :user_id
  belongs_to :category
  belongs_to :user
end