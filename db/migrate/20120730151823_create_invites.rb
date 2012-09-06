class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :email
      t.references :event

      t.timestamps
    end
    add_index :invites, :event_id

    add_column :invites, :inviter_id, :integer
  end
end
