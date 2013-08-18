class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.integer :guest_id
      t.integer :event_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0
      t.boolean :muted, default:false

      t.timestamps
    end

   add_index :rsvps, :guest_id
   add_index :rsvps, :event_id
   add_index :rsvps, [:guest_id, :event_id], unique: true
  end
end
