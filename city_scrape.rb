require 'rubygems'
require 'nokogiri'
require 'open-uri'


url = "http://en.wikipedia.org/wiki/List_of_United_States_cities_by_population"
doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text
doc.css(".wikitable").children().each do |item|
  city = item.at_css("a").text
end 
#   state = item.at_css(".PriceCompare .BodyS, .PriceXLBold").text[/\$[0-9\.]+/]

#   puts "#{city} ', ' #{state}"
# end