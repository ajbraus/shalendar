class AddMinAndMaxToEvents < ActiveRecord::Migration
  def change
    add_column :events, :min, :integer, :default => 1
    add_column :events, :max, :integer, :default => 10000
  end
end
