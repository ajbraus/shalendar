class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :invited_user_id
      t.integer :pending_plan_id
      t.timestamps
    end

   add_index :invitations, :invited_user_id
   add_index :invitations, :pending_plan_id
   add_index :invitations, [:invited_user_id, :pending_plan_id], unique: true
  end
end
