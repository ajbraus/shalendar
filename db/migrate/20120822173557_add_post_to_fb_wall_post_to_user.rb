class AddPostToFbWallPostToUser < ActiveRecord::Migration
  def change
    add_column :users, :post_to_fb_wall, :boolean
  end
end
