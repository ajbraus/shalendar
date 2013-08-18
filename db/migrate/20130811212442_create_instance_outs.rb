class CreateInstanceOuts < ActiveRecord::Migration
  def change
    create_table :instance_outs do |t|
      t.integer :user_id
      t.integer :instance_id

      t.timestamps
    end

   add_index :instance_outs, :user_id
   add_index :instance_outs, :instance_id
   add_index :instance_outs, [:user_id, :instance_id], unique: true
  end
end