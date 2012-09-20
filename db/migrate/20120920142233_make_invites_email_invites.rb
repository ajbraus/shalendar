class MakeInvitesEmailInvites < ActiveRecord::Migration
	def change
		#**UPDATE, does this index on pair work for sure? should it be in model or something instead?
		add_index :invites, [:event_id, :email], unique: true
		rename_table :invites, :email_invites
	end
end
