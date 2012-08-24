class AddInviterToInvites < ActiveRecord::Migration
  def change
  	add_column :events, :inviter_id, :integer
  end
end
