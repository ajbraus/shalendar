class AddFollowUpToUser < ActiveRecord::Migration
  def change
  	add_column :users, :follow_up, :boolean
  end
end
