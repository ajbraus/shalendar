class AddFriendsOfFriendsBoolean < ActiveRecord::Migration
  def change
    add_column :events, :friends_of_friends, :boolean, :default => true
  end
end
