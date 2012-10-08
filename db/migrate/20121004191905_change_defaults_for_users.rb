class ChangeDefaultsForUsers < ActiveRecord::Migration
  def change
 		change_column_default :users, :post_to_fb_wall, false
 		change_column_default :users, :require_confirm_follow, false
 	end
end
