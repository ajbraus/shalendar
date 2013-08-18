class CreateInstanceInvitations < ActiveRecord::Migration
  def change
    create_table :instance_invitations do |t|
      t.integer :user_id
      t.integer :instance_id
      t.integer :inviter_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0
      t.integer :randos_in, default: 0

      t.timestamps
    end

    add_index :instance_invitations, :user_id
    add_index :instance_invitations, :instance_id
    add_index :instance_invitations, [:user_id, :instance_id], unique: true
    add_index :instance_invitations, :inviter_id
  end
end
