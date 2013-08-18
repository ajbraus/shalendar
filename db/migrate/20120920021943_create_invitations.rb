class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id
      t.integer :event_id
      t.integer :inviter_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0
      t.integer :randos_in, default: 0


      t.timestamps
    end

    add_index :invitations, :user_id
    add_index :invitations, :event_id
    add_index :invitations, [:user_id, :event_id], unique: true
    add_index :invitations, :inviter_id
  end
end
