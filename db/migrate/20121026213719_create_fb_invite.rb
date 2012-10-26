class CreateFbInvite < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :fb_uid
      t.string :fb_pic_url
      t.integer :inviter_id
      t.references :event

      t.timestamps
    end

    add_index :invites, :fb_uid 
    add_index :invites, :event_id
		add_index :invites, [:event_id, :fb_uid], unique: true
  end
end
