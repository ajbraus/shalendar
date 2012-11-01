class Comment < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  attr_accessible :content

  validates :content, length: { maximum: 140 }

end
