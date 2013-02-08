class AddInmatesToRelationships < ActiveRecord::Migration
  def change
  	add_column :relationships, :status, :integer, default: 1
  	
  	#pruning
  	remove_column :relationships, :toggled
  	remove_column :events, :is_public
  	remove_column :events, :is_big_idea
  	remove_column :events, :min
  	remove_column :events, :guests_can_invite_friends
  	remove_column :rsvps, :invite_all_friends
  	remove_table :fb_invites
  	remove_table :suggestions

		#make all current relationships -> status = 2
		Relationship.all.each do |r|
			r.status = 2
			r.save
		end
		#add all facebook friends to inmates (create relationships with status = 1)
		User.all.each do |u|
			@member_friends = u.fb_friends(session[:graph])[0]
			@member_friends.each do |mf|
				u.inmate!(mf)
			end
		end

		#add all 'follow_ups' as status 1
  end
end
