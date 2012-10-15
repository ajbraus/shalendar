class RemoveOldApnsTuff < ActiveRecord::Migration
  def change
  	drop_table: apn_devices
  	drop_table: apn_notifications
  end

end
