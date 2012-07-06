class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.integer :guest_id
      t.integer :plan_id

      t.timestamps
    end

   add_index :rsvps, :guest_id
   add_index :rsvps, :plan_id
   add_index :rsvps, [:guest_id, :plan_id], unique: true
  end
end
