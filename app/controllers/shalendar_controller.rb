class ShalendarController < ApplicationController
	# before_filter :parse_facebook_cookies, :only => [:home, :find_friends]

	def home
		@users = User.all
		@relationships = current_user.relationships
		@access_token = session[:fb_access_token]
  	@graph = Koala::Facebook::API.new(@access_token)
	end

	def manage_follows
		@followers = current_user.followers
		@followed_users = current_user.followed_users
	end

	def find_friends
		@access_token = session[:fb_access_token]
		@graph = Koala::Facebook::API.new(@access_token)
		
		@friends = @graph.get_connections('me','friends',:fields => "name,picture,location")
		@me = @graph.get_object('me')
		
		@city_friends = @friends.select do |friend|
			friend['location'].present? && friend['location']['name'] == @me['location']['name']
		end

		@city_members = User.where('uid IN (?)', @city_friends.map {|friend| friend['id']} ) 
	end
end
