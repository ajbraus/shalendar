class AddPublicBoolToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :is_public, :boolean, default: false
  	add_column :events, :category, :string
    add_column :events, :family_friendly, :boolean, default: false

    Suggestion.all.each do |s|
    	s.destroy
    end

    unless User.find_by_email("info@hoos.in").nil?
     	User.find_by_email("info@hoos.in").events.each do |e|
     		e.is_public = true
     	end
    end

    remove_column :events, :suggestion_id
  end
end
