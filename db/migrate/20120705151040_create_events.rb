class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :title

      t.timestamps
    end

   	add_column :events, :user_id, :integer
   	add_column :events, :min, :integer, :default => 1
    add_column :events, :max, :integer, :default => 10000
    add_column :events, :duration, :float
    add_column :events, :visibility, :string
    add_column :events, :inviter_id, :integer, :default => 0
    add_column :events, :tipped, :bool, :default => false
    add_column :events, :link, :string
    add_column :events, :address, :string
    add_column :events, :longitude, :float
    add_column :events, :latitude, :float
    add_column :events, :gmaps, :boolean
  end
end
