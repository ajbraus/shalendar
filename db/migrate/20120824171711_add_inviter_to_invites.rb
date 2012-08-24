class AddInviterToInvites < ActiveRecord::Migration
  def change
  	add_column :invites, :inviter_id, :integer
  end
end
