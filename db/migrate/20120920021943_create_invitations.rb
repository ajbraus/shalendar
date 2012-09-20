class CreateInvitations < ActiveRecord::Migration
  def change
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
  end
end
