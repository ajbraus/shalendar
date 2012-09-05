class AddGcmToUser < ActiveRecord::Migration
  def change
  	add_column :users, :GCMdevice_id, :integer, :default => 0
  	add_column :users, :GCMregistration_id, :integer, :default => 0
  	add_column :users, :android_user, :bool, :default => false
  end
end
