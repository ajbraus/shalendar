class AddNumInmatesAndFriends < ActiveRecord::Migration
  def change
  	add_column :users, :friends_count, :integer, default: 0
  	add_column :users, :intros_count, :integer, default: 0
  	add_column :users, :friended_bys_count, :integer, default: 0

  	User.all.each do |u|
  		u.friends_count = u.friends.count
  		u.intros_count = u.inmates.count
  		u.friended_bys_count = u.friended_bys.count
  		u.save
  	end

  	add_column :events, :over, :boolean, default: false

  	Event.where('ends_at is NOT NULL').find_each do |e|
  		Time.zone = e.city.timezone
  		if e.ends_at < Time.zone.now
  			e.over = true
  			@parent = e.parent
  			if @parent.present? && @parent.one_time?
  				@parent.over = true
  				@parent.save
  			end
  		else
  			e.over = false
  			if @parent.present?
  				@parent.over = false
  				@parent.save
  			end
  		end
  		e.save
  	end

  	add_index :relationships, ["follower_id", "followed_id", "status"]
  end
end
