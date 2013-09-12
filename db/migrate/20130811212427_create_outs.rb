class CreateOuts < ActiveRecord::Migration
  def change
    create_table :outs do |t|
      t.integer :user_id
      t.integer :event_id
      t.integer :outable_id
      t.string :outable_type

      t.timestamps
    end

   add_index :outs, :outable_id
   add_index :outs, :user_id
   add_index :outs, :event_id
   add_index :outs, [:user_id, :event_id], unique: true
  end
end