class UserEventsAssociation < ActiveRecord::Migration
  def change
		add_column :events, :user_id, :integer
		rename_column :events, :end, :end_datetime
		rename_column :events, :start, :start_datetime
	end
end

