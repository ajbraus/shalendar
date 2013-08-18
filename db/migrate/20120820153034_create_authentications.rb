class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.string :pic_url
      t.string :city
      t.references :user

      t.timestamps
    end
    add_index :authentications, :user_id
    add_index :authentications, :uid, unique: true
  end
end
