class ApnDeviceId < ActiveRecord::Migration
  def change
  	add_column :users, :apn_device_id, :integer, :default => 0
  end
end
