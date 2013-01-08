class AddOneTimeToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :one_time, :boolean, default: false

  	Event.all.each do |e|
  		e.one_time = true
  		e.save
  	end
  	
  end
end
