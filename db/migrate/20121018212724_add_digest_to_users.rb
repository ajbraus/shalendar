class AddDigestToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :digest, :boolean, default: true
  end
end
