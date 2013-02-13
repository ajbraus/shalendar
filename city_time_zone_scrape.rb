require 'rubygems'
require 'nokogiri'
require 'open-uri'


zone_url = "http://en.wikipedia.org/wiki/List_of_time_zones_by_U.S._state"
zone_doc = Nokogiri::HTML(open(zone_url))

puts zone_doc.at_css("title").text
zone_doc.css('.wikitable').children().css('td').each do |zone_item|
	zone_item = "#{zone_item.text}"
	zone_array = zone_item.split(%r{\n})
	zone_array = zone_array.reject { |za| za.length > 15 || za.length < 4 || za.include?('0') || ( za.length == 4 && za.include?('P') )}
	zones = zone_array.join(', ')
	puts zone_array
end 
#   state = item.at_css(".PriceCompare .BodyS, .PriceXLBold").text[/\$[0-9\.]+/]

#   puts "#{city} ', ' #{state}"
# end