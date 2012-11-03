class RemovingCreatorFromComments < ActiveRecord::Migration
  def change
  	Comment.all.each do |c|
  		User.all.each do |u|
  			if c.creator == u.name
  				c.user_id = u.id 
  				c.save
  			end
  		end
  	end

  	remove_column :comments, :creator
  end
end
