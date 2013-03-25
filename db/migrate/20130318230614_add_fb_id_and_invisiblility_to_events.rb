class AddFbIdAndInvisiblilityToEvents < ActiveRecord::Migration
  def change
  	Event.all.each do |e|
  		if e.friends_only?
  			e.visibility = 1
  		else
  			e.visibility = 2
  		end
  		e.save
  	end

    remove_column :events, :friends_only

  end
end