class ShalendarController < ApplicationController
  # before_filter :authenticate_user!
	# before_filter :parse_facebook_cookies, :only => [:home, :find_friends]

	autocomplete :user, :email

	def home
		@current_user = current_user
		@relationships = current_user.relationships.where('relationships.confirmed = true')
  	@graph = Koala::Facebook::API.new(session[:access_token])
  	@event = Event.new

  	#@first_date_on_calendar = Date.today #how to change this w/ button?

    # @morning_plans = []
    # @afternoon_plans = []
    # @evening_plans = []
    # @finished_morning_plans = []

    # @current_user.plans.each do |e|
    #   if e.starts_at.to_date == Date.today #won't work for >2 day events
    #     if e.ends_at >= Time.now
        	

    #     	@_plans.push(e)
    #   	end
    #   end
    # end


	end

	def mobile_home
		@mobile_user = User.find_by_id(3)
  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_user }
    end	
	end

	def mobile_followed_users
		@mobile_user = User.find_by_id(3)
		@mobile_followed_users = @mobile_user.followed_users

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_followed_users }
    end
  end

	def mobile_toggled_followed_users
		@mobile_user = User.find_by_id(3)
		@mobile_followed_users = @mobile_user.followed_users
		@mobile_toggled_followed_users = []
		
		@mobile_followed_users.each do |mfu|
			@mfu_relationship = Relationship.where("relationships.follower_id = :mobile_user_id AND relationships.followed_id = :mfu_id",
												 :mobile_user_id => @mobile_user.id, :mfu_id => mfu.id)
			if @mfu_relationship.toggled?
				@mobile_toggled_followed_users.push(mfu)
			end
		end

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_toggled_followed_users }
    end
	end

	def mobile_untoggled_followed_users
		@mobile_user = User.find_by_id(3)
		@mobile_followed_users = @mobile_user.followed_users
		@mobile_untoggled_followed_users = []

		@mobile_followed_users.each do |mfu|
			unless Relationship.where("follower_id = :mobile_user_id AND followed_id = :mfu_id", mobile_user_id: @mobile_user.id, mfu_id: mfu.id).toggled?
				@mobile_untoggled_followed_users.push(mfu)
			end
		end
		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_untoggled_followed_users }
    end
	end

	# def mobile_toggled_follows
	# 	@mobile_user = User.find_by_id(3)
	# 	@mobile_toggled_follows = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
 #                                    .where('relationships.follower_id = :current_user_id AND 
 #                                      relationships.toggled = true AND relationships.confirmed = true',
 #                                      :current_user_id => @mobile_user.id)

	# end
	def mobile_followers
		@mobile_user = User.find_by_id(3)
		@mobile_followers = @mobile_user.followers
		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_followers }
    end
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
		if session[:access_token] 
	  	@graph = Koala::Facebook::API.new(session[:access_token])
			@friends = @graph.get_connections('me','friends',:fields => "name,picture,location")
			@me = @graph.get_object('me')
			
			@city_friends = @friends.select do |friend|
				friend['location'].present? && friend['location']['name'] == @me['location']['name']
			end

			@fb_authentications = Authentication.where('uid IN (?)', @city_friends.map {|friend| friend['id']} )
			
			@city_members = []
			@fb_authentications.each do |fa|
				@city_members.push(fa.user)
			end
		else
			redirect_to user_omniauth_callback_path
		end
	end
end
