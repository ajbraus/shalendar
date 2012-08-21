class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :useremail
      t.string :username
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.string :name
      t.string :link
      t.references :user

      t.timestamps
    end
    add_index :authentications, :user_id
  end
end
