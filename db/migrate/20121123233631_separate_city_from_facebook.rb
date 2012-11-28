class SeparateCityFromFacebook < ActiveRecord::Migration
  def change
  	add_column :users, :city_id, :int
    add_column :authentications, :city, :string

    City.all.each do |c|
      c.destroy
    end

    City.create(name: "Everywhere Else", timezone: nil)
    City.create(name: "Madison, Wisconsin", timezone: "Central Time (US & Canada)")

  	User.all.each do |u|
      u.authentications.each do |auth|
        auth.city = u.city
        auth.save
      end
      if u.city == "Madison, Wisconsin" || u.city == "Middleton, Wisconsin" || u.city == "La Crosse, Wisconsin" || u.city == "Appleton, Wisconsin" || u.city == "Whitewater, Wisconsin" || u.city == "Platteville, Wisconsin"
        u.city_id = City.find_by_name("Madison, Wisconsin").id
        u.time_zone = "Central Time (US & Canada)"
      else
        u.city_id = City.find_by_name("Everywhere Else").id
        u.time_zone = nil
      end
      u.save
  	end
    add_column :events, :city_id, :int

    Event.all.each do |e|
      if e.user.nil?
        e.city_id = City.find_by_name("Everywhere Else").id
      else
        e.city_id = e.user.city_id
      end
    end

    remove_column :users, :city
    
  end
end
