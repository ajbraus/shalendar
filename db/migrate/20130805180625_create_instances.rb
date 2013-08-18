class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.references :event
      t.references :city
      t.datetime :starts_at
      t.datetime :ends_at
      t.float :duration
      t.boolean :over, default: false

      t.timestamps
    end
    add_index :instances, :event_id
  end
end
