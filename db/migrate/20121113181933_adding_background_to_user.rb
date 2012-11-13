class AddingBackgroundToUser < ActiveRecord::Migration
  def up
  	add_attachment :users, :background
  end

  def down
  	remove_attachment :users, :background
  end
end
