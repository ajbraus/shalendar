class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :invitee_id
      t.integer :inviteable_id
      t.string :inviteable_type
      t.integer :inviter_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0
      t.integer :randos_in, default: 0


      t.timestamps
    end

    add_index :invites, [:inviteable_id, :inviteable_type]
    add_index :invites, [:invitee_id, :inviteable_type]
    add_index :invites, [:invitee_id, :inviteable_id, :inviteable_type], unique: true, name: "unique_invites_index"
    add_index :invites, :inviter_id
  end
end
