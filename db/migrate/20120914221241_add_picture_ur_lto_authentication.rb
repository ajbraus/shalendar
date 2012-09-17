class AddPictureUrLtoAuthentication < ActiveRecord::Migration
  def change
  	add_column :authentications, :pic_url, :string
  end

end
