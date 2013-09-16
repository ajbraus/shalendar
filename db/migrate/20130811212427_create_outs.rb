class CreateOuts < ActiveRecord::Migration
  def change
    create_table :outs do |t|
      t.integer :flake_id
      t.integer :outable_id
      t.string :outable_type

      t.timestamps
    end

   add_index :outs, [:outable_id, :outable_type]
   add_index :outs, [:flake_id, :outable_type]
   add_index :outs, [:flake_id, :outable_id, :outable_type], unique: true
  end
end