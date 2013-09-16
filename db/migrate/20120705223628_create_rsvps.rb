class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.integer :guest_id
      t.integer :friends_in, default: 0
      t.integer :intros_in, default: 0
      t.integer :randos_in, default: 0
      t.boolean :muted, default:false
      t.integer :rsvpable_id
      t.string :rsvpable_type

      t.timestamps
    end

   add_index :rsvps, [:rsvpable_id, :rsvpable_type]
   add_index :rsvps, [:guest_id, :rsvpable_type]
   add_index :rsvps, [:guest_id, :rsvpable_id, :rsvpable_type], unique: true
  end
end
