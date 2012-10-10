class AddEmailCommentsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :email_comments, :boolean, :default => true
  	add_column :users, :admin, :boolean, :default => false
  end
end
