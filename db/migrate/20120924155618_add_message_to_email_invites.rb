class AddMessageToEmailInvites < ActiveRecord::Migration
  def change
    add_column :email_invites, :message, :string
  end
end
