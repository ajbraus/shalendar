class AddApnTokenToUser < ActiveRecord::Migration
  def change
  	add_column :users, :APNtoken, :string
  	add_column :users, :iPhone_user, :bool, :default => false
  end
end
