class ShalendarController < ApplicationController
  before_filter :authenticate_user!

	def home
		@relationships = current_user.relationships.where('relationships.confirmed = true')
  	@graph = Koala::Facebook::API.new(session[:access_token])
  	@event = Event.new
    @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
                                         relationships.confirmed = false ", current_user_id: current_user.id)

    @next_plan = current_user.plans.order("starts_at desc").last
    
    if params[:search]
      @users = User.search(params[:search]).limit(5)
      respond_to do |f|
        f.js { render "user_search_results" }
      end
    end

    if session[:access_token] 
      @graph = Koala::Facebook::API.new(session[:access_token])
      @friends = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
      @me = @graph.get_object('me')

      @city_friends = @friends.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
    end

    if params[:date] 
      @forecastevents = current_user.forecast(params[:date])
      @date = Date.strptime(params[:date], "%Y-%m-%d")
      # respond_to do |f|
      #   f.html
      #   f.js { render "forecast" }
      # end
    else
      @forecastevents = current_user.forecast((Date.today).to_s)
      @date = Date.today
      # respond_to do |f|
      #   f.html
      #   f.js { render "forecast" }
      # end
    end
    @forecastoverview = current_user.forecastoverview

	end

	def manage_follows
		@graph = Koala::Facebook::API.new(session[:access_token])
		
		#people viewing current user 
		@follower_relationships = Relationship.where("relationships.followed_id = :current_user_id AND 
																									relationships.confirmed = true ", current_user_id: current_user.id)
		#people who want to view current user
		@view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
											 									 relationships.confirmed = false ", current_user_id: current_user.id)
		#people current user is viewing
		@followed_user_relationships = Relationship.where("relationships.follower_id = :current_user_id",
																											 current_user_id: current_user.id)
	 
   @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
                                         relationships.confirmed = false ", current_user_id: current_user.id)


    if params[:search]
      @users = User.search params[:search]
      respond_to do |f|
        f.js { render "user_search_results" }
      end
    end
  end

  def invite
    @graph = Koala::Facebook::API.new(session[:access_token])
    @graph.put_wall_post("I just joined Hoos.in and want to invite you too. ~#{current_user.first_name}", {:name => "Hoos.in", :link => "http://www.hoos.in"}, "#{params[:username]}")
    redirect_to :back
  end

end
