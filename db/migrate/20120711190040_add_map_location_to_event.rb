class AddMapLocationToEvent < ActiveRecord::Migration
  def change
    add_column :events, :map_location, :string
  end
end
