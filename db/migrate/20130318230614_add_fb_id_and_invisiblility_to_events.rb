class AddFbIdAndInvisiblilityToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :fb_id, :string
  	add_index :events, :fb_id
  end
end
