class SeparateCityFromFacebook < ActiveRecord::Migration
  def change
  	add_column :users, :city_id, :int
    add_column :authentications, :city, :string

    add_column :users, :slug, :string
    add_index :users, :slug

    User.find_each(&:save)

    if City.all.any?
      City.all.each do |c|
        c.destroy
      end
    end

    City.create(name: "Madison, Wisconsin", timezone: "Central Time (US & Canada)")
    City.create(name: "Chicago, Illinois", timezone: "Central Time (US & Canada)")
    City.create(name: "New York- Manhattan, New York", timezone: "Eastern Time (US & Canada)")
    City.create(name: "New York- Brooklyn, New York", timezone: "Eastern Time (US & Canada)")
    City.create(name: "New York- Long Island, New York", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Minneapolis, Minnesota", timezone: "Central Time (US & Canada)")
    City.create(name: "Detroit, Michigan", timezone: "Central Time (US & Canada)")
    City.create(name: "Austin, Texas", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Portland, Oregon", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Seattle, Washington", timezone: "Pacific Time (US & Canada)")
    City.create(name: "San Francisco, California", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Los Angeles, California", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Las Vegas, Nevada", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Denver, Colorado", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Houston, Texas", timezone: "Central Time (US & Canada)")
    City.create(name: "Philadelphia, Pennsylvania", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Phoenix, Arizona", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Indianapolis, Indiana", timezone: "Central Time (US & Canada)")
    City.create(name: "Dallas, Texas", timezone: "Central Time (US & Canada)")
    City.create(name: "Boston, Massachusetts", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Washington, D.C.", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Baltimore, Maryland", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Pittsburgh, Pennsylvania", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Milwaukee, Wisconsin", timezone: "Central Time (US & Canada)")
    City.create(name: "Atlanta, Georgia", timezone: "Eastern Time (US & Canada)")
    City.create(name: "New Orleans, Louisiana", timezone: "Central Time (US & Canada)")
    City.create(name: "Miami, Florida", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Boulder, Colorado", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Salt Lake City, Utah", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Charlotte, North Carolina", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Cincinatti, Ohio", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Portland, Maine", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Nashville, Tennessee", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Santa Fe, New Mexico", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Ann Arbor, Michigan", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Kansas City, Missouri", timezone: "Central Time (US & Canada)")
    City.create(name: "Missoula, Montana", timezone: "Mountain Time (US & Canada)")
    City.create(name: "Palm Springs, California", timezone: "Eastern Time (US & Canada)")
    City.create(name: "San Diego, California", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Toronto, Canada", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Montreal, Canada", timezone: "Eastern Time (US & Canada)")
    City.create(name: "Vancouver, Canada", timezone: "Pacific Time (US & Canada)")
    City.create(name: "Bangkok, Thailand", timezone: "Bangkok")
    City.create(name: "Seoul, Korea", timezone: "Seoul")
    City.create(name: "Istanbul, Turkey", timezone: "Istanbul")
    City.create(name: "Stockholm, Sweden", timezone: "Paris")
    City.create(name: "London, England", timezone: "London")


    if User.all.any?
    	User.all.each do |u|
        u.authentications.each do |auth|
          auth.city = u.city
          auth.save
        end
        if u.city == "Boston, Massachusetts"
          u.city_id = City.find_by_name("Boston, Massachusetts").id
        elsif u.city == "Chicago, Illinois"
          u.city_id = City.find_by_name("Chicago, Illinois").id
        elsif u.city == "New York, New York" || u.city == "Manhattan, New York" || u.city == "Ithaca, New York" || u.city == "Warren, New Jersey"
          u.city_id = City.find_by_name("New York- Manhattan, New York").id
        elsif u.city == "San Francisco, California"
          u.city_id = City.find_by_name("San Francisco, California").id
        elsif u.city == "Salt Lake City, Utah"
          u.city_id = City.find_by_name("Salt Lake City, Utah").id
        elsif u.city == "Istanbul, Turkey"
          u.city_id = City.find_by_name("Istanbul, Turkey").id
        elsif u.city == "Atlanta, Georgia"
          u.city_id = City.find_by_name("Atlanta, Georgia").id
        elsif u.city == "Istanbul, Turkey"
          u.city_id = City.find_by_name("Istanbul, Turkey").id
        elsif u.city == "Las Vegas, Nevada"
          u.city_id = City.find_by_name("Las Vegas, Nevada").id
        elsif u.city == "Phoenix, Arizona"
          u.city_id = City.find_by_name("Phoenix, Arizona").id
        elsif u.city == "Minneapolis, Minnesota" || u.city == "Northfield, Minnesota"
          u.city_id = City.find_by_name("Minneapolis, Minnesota").id
        elsif u.city == "Boulder, Colorado" || u.city == "Colorado Springs, Colorado"
          u.city_id = City.find_by_name("Boulder, Colorado").id
        elsif u.city == "Stockholm, Sweden"
          u.city_id = City.find_by_name("Stockholm, Sweden").id
        elsif u.city == "Milwaukee, Wisconsin"
          u.city_id = City.find_by_name("Milwaukee, Wisconsin").id
        elsif u.city == "Portland, Oregon"
          u.city_id = City.find_by_name("Portland, Oregon").id
        elsif u.city == "Oxford, Oxfordshire"
          u.city_id = City.find_by_name("London, England").id
        else #u.city == "Madison, Wisconsin" || u.city == "Middleton, Wisconsin" || u.city == "La Crosse, Wisconsin" || u.city == "Appleton, Wisconsin" || u.city == "Whitewater, Wisconsin" || u.city == "Platteville, Wisconsin" || u.city == "Portage, Wisconsin"
          u.city_id = City.find_by_name("Madison, Wisconsin").id
        end
        u.save
    	end
    end
    add_column :events, :city_id, :int

    if Event.all.any?
      Event.all.each do |e|
        if e.user.nil?
          e.city_id = City.find_by_name("Everywhere Else").id
        else
          e.city_id = e.user.city_id
        end
      end
    end

    remove_column :users, :city
    
  end
end
