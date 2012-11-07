class AddFamilyFriendlyBoolToUser < ActiveRecord::Migration
  def change
  	add_column :users, :family_filter, :boolean

  	User.all.each do |u|
  		u.family_filter = false
  		u.save
  	end
  end
end
