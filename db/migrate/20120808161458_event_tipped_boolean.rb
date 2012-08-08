class EventTippedBoolean < ActiveRecord::Migration
  def change
  	add_column :events, :tipped, :boolean
  end
end
