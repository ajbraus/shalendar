class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.references :user
      t.references :event

      t.timestamps
    end
    add_index :comments, :event_id
  end
end
