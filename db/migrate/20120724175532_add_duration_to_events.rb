class AddDurationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :duration, :decimal, :precision => 2, :scale => 2
  end
end
