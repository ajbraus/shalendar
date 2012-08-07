class RemoveLocationFromEvent < ActiveRecord::Migration
  def change
  	remove_column :events, :location
  end
end
