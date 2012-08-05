class Comment < ActiveRecord::Base
  belongs_to :event
  attr_accessible :content

  validates :content, length: { maximum: 140 }
end
