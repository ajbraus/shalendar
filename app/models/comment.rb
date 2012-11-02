class Comment < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  attr_accessible :content

  validates :content, length: { maximum: 240 }


  def user_name
  	if !comment.user.nil?
  		comment.user.name
  	else
  		comment.creator
  	end
  end
end
