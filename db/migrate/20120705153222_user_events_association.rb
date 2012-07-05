dsclass UserEventsAssociation < ActiveRecord::Migration
  def change
		add_column :events, :user_id, :integer
		rename_column :events, :end, :ends_at
		rename_column :events, :start, :starts_at
	end
end

