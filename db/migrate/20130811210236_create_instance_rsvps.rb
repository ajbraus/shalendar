class CreateInstanceRsvps < ActiveRecord::Migration
  def change
    create_table :instance_rsvps do |t|
      t.integer :user_id
      t.integer :instance_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0

      t.timestamps
    end

   add_index :instance_rsvps, :user_id
   add_index :instance_rsvps, :instance_id
   add_index :instance_rsvps, [:user_id, :instance_id], unique: true
  end
end

