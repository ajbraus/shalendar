class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    add_index :categories, :name

    create_table :interests do |t|
    	t.integer :category_id
    	t.integer :user_id

    	t.timestamps
    end
    add_index :interests, :category_id
    add_index :interests, :user_id

    create_table :categorizations, :id => false do |t|
    	t.integer :category_id
    	t.integer :event_id

    	t.timestamps
    end
    add_index :categorizations, :category_id
    add_index :categorizations, :event_id
  end
end
