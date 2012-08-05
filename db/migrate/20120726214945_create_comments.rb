class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.string :creator
      t.references :event

      t.timestamps
    end
    add_index :comments, :event_id
  end
end
