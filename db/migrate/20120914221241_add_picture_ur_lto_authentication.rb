class AddPictureUrLtoAuthentication < ActiveRecord::Migration
  def change
  	add_column :authentications, :profile_picture_url, :string
  end
end
