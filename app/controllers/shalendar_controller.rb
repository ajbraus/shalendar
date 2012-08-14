class ShalendarController < ApplicationController
  # before_filter :authenticate_user!
	# before_filter :parse_facebook_cookies, :only => [:home, :find_friends]

	autocomplete :user, :email

	def home
		@current_user = current_user
		@users = User.all
		@relationships = current_user.relationships.where('relationships.confirmed = true')
		@access_token = session[:fb_access_token]
  	@graph = Koala::Facebook::API.new(@access_token)
  	@event = Event.new
	end

	def manage_follows
		@graph = Koala::Facebook::API.new(@access_token)
		# @followers = current_user.followers
		# @followed_users = current_user.followed_users

		#people viewing current user 
		@follower_relationships = Relationship.where("relationships.followed_id = :current_user_id AND 
																									relationships.confirmed = true ", current_user_id: current_user.id)
		#people who want to view current user
		@view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
											 									 relationships.confirmed = false ", current_user_id: current_user.id)
		#people current user is viewing
		@followed_user_relationships = Relationship.where("relationships.follower_id = :current_user_id",
																											 current_user_id: current_user.id)
		
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
