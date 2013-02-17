class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    add_index :categories, :name
    # add_column :users, :classification_id, :integer #to sort venues

    create_table :interests do |t|
    	t.integer :category_id
    	t.integer :user_id

    	t.timestamps
    end
    add_index :interests, :category_id
    add_index :interests, :user_id

    create_table :categorizations do |t|
    	t.integer :category_id
    	t.integer :event_id

    	t.timestamps
    end
    add_index :categorizations, :category_id
    add_index :categorizations, :event_id

    # Category.create(id:1,name:"Adventure")
    # Category.create(id:2,name:"Learn")
    # Category.create(id:3,name:"Creative")
    # Category.create(id:4,name:"Night")
    # Category.create(id:5,name:"Active")
    # Category.create(id:6,name:"Music")

    # Event.all.each do |e|
    #   Category.all.each do |cat|
    #     if e.category.present?
    #         if e.category.downcase == cat.name.downcase
    #           Categorization.create(event_id:e.id, category_id:cat.id)
    #         end
    #     end
    #   end
    # end

    remove_column :events, :category
    
  end
end
