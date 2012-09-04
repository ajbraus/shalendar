class AddEventTippedBool < ActiveRecord::Migration
	def change
	 	add_column :events, :tipped, :bool, :default => false
	end
end
