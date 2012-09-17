class AddPictureUrLtoAuthentication < ActiveRecord::Migration
  def change
  	add_column :authentications, :pic_url, :string
  end
	
	@graph = Koala::Facebook::API.new
  Authentication.all do |a|
  a.update_attributes!(:pic_url => "#{@graph.get_picture(a.uid)}")
  end

end
