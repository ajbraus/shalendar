class AddSlugToUser < ActiveRecord::Migration
  def change
  	add_column :users, :slug, :string
  	add_index :users, :slug

  	remove_column :users, :time_zone

  	User.find_each(&:save)
  end
end