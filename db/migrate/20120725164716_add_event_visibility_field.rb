class AddEventVisibilityField < ActiveRecord::Migration

  def change

  	remove_column :events, :friends_of_friends, :boolean
  	
  	add_column :events, :visibility, :string

  end
end
