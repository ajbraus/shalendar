class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :title

      t.timestamps
    end

   	add_column :suggestions, :user_id, :integer
   	add_column :suggestions, :min, :integer, :default => 1
    add_column :suggestions, :max, :integer, :default => 10000
    add_column :suggestions, :duration, :float
    add_column :suggestions, :link, :string
    add_column :suggestions, :address, :string
    add_column :suggestions, :longitude, :float
    add_column :suggestions, :latitude, :float
    add_column :suggestions, :gmaps, :boolean
    
    add_column :suggestions, :category, :string
    add_column :suggestions, :price, :float
    add_column :suggestions, :family_friendly, :boolean

    add_column :users, :vendor, :bool, :default => false
    add_column :events, :suggestion_id, :integer
  end
end
