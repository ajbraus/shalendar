class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :start
      t.datetime :end
      t.string :title
      t.string :description
      t.string :location

      t.timestamps
    end
  end
end
