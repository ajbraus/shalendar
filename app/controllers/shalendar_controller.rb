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
			
		@city_friends = []

		@friends.each do |f|
			if f[:location] == @me[:location]
				@city_friends.push(f)
			end
		end
	end



	protected
		def parse_facebook_cookies
	  	@facebook_cookies ||= Koala::Facebook::OAuth.new("327936950625049", "4d3de0cbf2ce211f66733f377b5e3816").get_user_info_from_cookie(cookies)
		end
end
