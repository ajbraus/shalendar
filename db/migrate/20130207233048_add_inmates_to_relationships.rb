class AddInmatesToRelationships < ActiveRecord::Migration
  def change
  	add_column :relationships, :status, :integer
  	add_column :events, :dead, :boolean, default: false
    add_column :events, :friends_only, :boolean, default: false
    add_column :rsvps, :muted, :boolean, default: false

    Event.all.each do |e|
      if e.user.rsvps.find_by_plan_id(e.id).present?
        if e.user.rsvps.find_by_plan_id(e.id).invite_all_friends == false
          e.friends_only = true
        end
      else
        e.friends_only = true
      end
      e.save
    end

  	#pruning
  	remove_column :relationships, :toggled
  	remove_column :events, :is_public
  	remove_column :events, :is_big_idea
  	remove_column :events, :min
  	remove_column :events, :guests_can_invite_friends
    remove_column :events, :tipped
  	remove_column :rsvps, :invite_all_friends
  	remove_column :users, :require_confirm_follow
  	remove_column :relationships, :confirmed
  	drop_table :fb_invites
  	drop_table :suggestions
  	drop_table :invitations
    drop_table :interests
    drop_table :categories
    drop_table :categorizations

		#make all current relationships -> status = 2
		Relationship.all.each do |r|
			r.status = 1
			r.save
		end
		
		User.all.each do |u|
    #add all ppl you've been to events with before already as inmates
      u.plans.each do |e|
        @inmates = e.guests.reject { |g| u.is_friends_with?(g) || u == g }
        @inmates.each do |i|
          u.inmate!(i)
        end
      end
		end 

  end
  
end
