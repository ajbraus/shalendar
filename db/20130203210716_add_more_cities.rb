class AddMoreCities < ActiveRecord::Migration
  def change
  
  City.create(name: "Albuquerque, New Mexico", timezone: "Mountain Time (US & Canada)")

  end
end
