class AddDemographicsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :female, :boolean
  	add_column :users, :birthday, :datetime
  end
end
