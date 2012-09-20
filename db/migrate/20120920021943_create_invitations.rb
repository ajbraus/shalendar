class CreateInvitations < ActiveRecord::Migration
  def change
    #**UPDATE- should we use t.reference for event instead of invited_event_id?
    create_table :invitations do |t|
      t.integer :invited_user_id
      t.integer :invited_event_id
      t.integer :inviter_id

      t.timestamps
    end

    add_index :invitations, :invited_user_id
    add_index :invitations, :invited_event_id
    add_index :invitations, :inviter_id
    add_index :invitations, [:invited_user_id, :invited_event_id], unique: true
  
    add_column :events, :invite_all_friends, :boolean
    add_column :events, :guests_can_invite_friends, :boolean

    Event.all.each do |e|
      if e.visibility == "friends_of_friends"
        e.invite_all_friends = true
        e.user.invite_all_friends!(e)
        e.guests_can_invite_friends = true
      elsif e.visibility == "invite_only"
        e.invite_all_friends = false
        e.guests_can_invite_friends = false
      else
        e.invite_all_friends = true
        e.user.invite_all_friends!(e)
        e.guests_can_invite_friends = false
      end
    end
    remove_column :events, :visibility
  end
end
