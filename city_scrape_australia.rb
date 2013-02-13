require 'rubygems'
require 'nokogiri'
require 'open-uri'


url = "http://en.wikipedia.org/wiki/List_of_cities_in_Australia_by_population"
doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text
#cities = ["Ann Arbor, Michigan", "Atlanta, Georgia", "Austin, Texas", "Baltimore, Maryland", "Bangkok, Thailand", "Boston, Massachusetts", "Boulder, Colorado", "Charlotte, North Carolina", "Chicago, Illinois", "Cincinatti, Ohio", "Columbus, Ohio", "Dallas, Texas", "Denver, Colorado", "Detroit, Michigan", "El Paso, Texas", "Fort Worth, Texas", "Houston, Texas", "Indianapolis, Indiana", "Istanbul, Turkey", "Ithaca, New York", "Jacksonville, Florida", "Kansas City, Missouri", "Las Vegas, Nevada", "London, England", "Los Angeles, California", "Louiseville, Kentucky", "Madison, Wisconsin", "Memphis, Tennessee", "Miami, Florida", "Middleton, Wisconsin", "Milwaukee, Wisconsin", "Minneapolis, Minnesota", "Missoula, Montana", "Montreal, Canada", "Nashville, Tennessee", "New Orleans, Louisiana", "New York, New York", "Oklahoma City, Oklahoma", "Palm Springs, California", "Philadelphia, Pennsylvania", "Phoenix, Arizona", "Pittsburgh, Pennsylvania", "Portland, Maine", "Portland, Oregon", "Salt Lake City, Utah", "San Antonio, Texas", "San Diego, California", "San Francisco, California", "San Jose, California", "Santa Fe, New Mexico", "Sao Paulo, Brazil", "Seattle, Washington", "Seoul, Korea", "Singapore", "Stockholm, Sweden", "Toronto, Canada", "Vancouver, Canada", "Washington, D.C."] 
doc.css(".wikitable").first().children().each do |item|
  city_data = item.text
  city_name_state = city_data.split(%r{\n})[1,2]
  if city_name_state[0].end_with?(']')
  	city_name_state[0].chop!
  	city_name_state[0].chop!
  	city_name_state[0].chop!
  end
  name_state = city_name_state.join(', ')
  #unless cities.include?(name_state)
  	puts "City.create(name: '#{name_state}', timezone: 'Mountain Time (US & Canada)')"
  #end
end 
#   state = item.at_css(".PriceCompare .BodyS, .PriceXLBold").text[/\$[0-9\.]+/]

#   puts "#{city} ', ' #{state}"
# end