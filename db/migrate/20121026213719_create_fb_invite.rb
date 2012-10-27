class CreateFbInvite < ActiveRecord::Migration
  def change
    create_table :fb_invites do |t|
      t.string :uid
      t.string :fb_pic_url
      t.string :name
      t.integer :inviter_id
      t.references :event

      t.timestamps
    end

    add_index :fb_invites, :uid 
    add_index :fb_invites, :event_id
		add_index :fb_invites, [:event_id, :uid], unique: true
  end
end
