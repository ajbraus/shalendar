class MakeFollowUpDefaultTrue < ActiveRecord::Migration
  def change
  	change_column_default :users, :follow_up, true
  end
end
