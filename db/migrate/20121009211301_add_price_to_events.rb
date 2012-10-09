class AddPriceToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :price, :float
  end
end
