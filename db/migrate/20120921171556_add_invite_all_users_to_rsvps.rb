class AddInviteAllUsersToRsvps < ActiveRecord::Migration
  def change


    Relationship.all.each do |r|
    	if r.confirmed == true
    		if r.followed.following?(r.follower) # do nothing, already both ways
    		elsif r.followed.request_following?(r.follower)
    			@relationship = r.followed.relationships.find_by_followed_id(r.follower_id)
    			@relationship.confirmed = true
    			@relationship.save
    		else
    			r.followed.follow!(r.follower)
    			@relationship = r.followed.relationships.find_by_followed_id(r.follower_id)
    			@relationship.confirmed = true
    			@relationship.save
    		end
    	end # do nothing, unconfirmed follow requests are the same as unconfirmed friend requests
    end
  end
end
