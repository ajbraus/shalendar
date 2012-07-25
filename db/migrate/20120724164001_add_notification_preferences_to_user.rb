class AddNotificationPreferencesToUser < ActiveRecord::Migration
  def change

  	add_column :users, :require_confirm_follow, :boolean, :default => true
  	add_column :users, :notify_noncritical_change, :boolean, :default => false
  	add_column :users, :daily_digest, :boolean, :default => true
  	add_column :users, :notify_event_reminders, :boolean, :default => true

  end
end
