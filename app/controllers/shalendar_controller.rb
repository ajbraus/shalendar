class ShalendarController < ApplicationController
	# before_filter :parse_facebook_cookies, :only => [:home, :find_friends]

	autocomplete :user, :email

	def home
		@current_user = current_user
		@users = User.all
		@relationships = current_user.relationships
		@access_token = session[:fb_access_token]
  	@graph = Koala::Facebook::API.new(@access_token)
  	@view_requests = Relationship.where("relationships.followed_id = :current_user_id AND 
  																				relationships.confirmed = 'f'", current_user_id: current_user.id)
	end

	def manage_follows
		@graph = Koala::Facebook::API.new(@access_token)
		# @followers = current_user.followers
		# @followed_users = current_user.followed_users
		@follower_relationships = current_user.reverse_relationships
		@followed_user_relationships = current_user.relationships
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
