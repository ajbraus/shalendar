class AddOneTimeToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :one_time, :boolean, default: false
  end
end
