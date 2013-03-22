class AddFbIdAndInvisiblilityToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :fb_id, :string
  	add_index :events, :fb_id
  	add_column :events, :visibility, :integer, default:2
  	remove_column :events, :friends_only

  	Event.all.each do |e|
  		if e.friends_only?
  			e.visibility = 1
  		else
  			e.visibility = 2
  		end
  		e.save
  	end

  end
end