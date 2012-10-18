class ChangeNameOfColumnsSuggestions < ActiveRecord::Migration
  def change
  	rename_column :suggestions, :lat, :latitude
  	rename_column :suggestions, :lng, :longitude
  end

end
