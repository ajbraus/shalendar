class MakeInvitesEmailInvites < ActiveRecord::Migration
	def change
		add_index :invites, [:event_id, :email], unique: true
		rename_table :invites, :email_invites
	end
end
