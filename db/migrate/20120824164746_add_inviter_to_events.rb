class AddInviterToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :inviter_id, :integer, :default => 0
  end
end
