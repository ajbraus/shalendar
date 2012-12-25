class ChangeNameOfGuestIdColumnInRsvps < ActiveRecord::Migration
  def change
    rename_column :rsvps, :guest_id, :user_id
	end
end
