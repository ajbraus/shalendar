class FixGcmRegistrationId < ActiveRecord::Migration
	def change
		remove_column :users, :GCMregistration_id
		add_column :users, :GCMtoken, :string
	end
end
