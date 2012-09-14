class ShalendarController < ApplicationController
  before_filter :authenticate_user!

	def home
		@relationships = current_user.relationships.where('relationships.confirmed = true')
  	@graph = session[:graph]
  	@event = Event.new
    # @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
    #                                      relationships.confirmed = false ", current_user_id: current_user.id)

    @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
    @forecastoverview = current_user.forecastoverview
    
    if params[:search]
      @users = User.search(params[:search]).limit(5)
      respond_to do |f|
        f.js { render "user_search_results" }
      end
    end
    if session[:access_token] 
      @graph = session[:graph]
      @friends = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
      @me = @graph.get_object('me')

      if @me['location'].nil? == false
        @city_friends = @friends.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
      else
        @city_friends = @friends
      end
    end

    if params[:date] 
      @forecastevents = current_user.forecast(params[:date])
      @date = Date.strptime(params[:date], "%Y-%m-%d")
      # respond_to do |f|
      #   f.html
      #   f.js { render "forecast" }
      # end
    else
      @forecastevents = current_user.forecast(Time.now.to_s)
      @date = Time.now.to_date
      # respond_to do |f|
      #   f.html
      #   f.js { render "forecast" }
      # end
    end

	end

	def manage_follows
		@graph = session[:graph]
		
		#people viewing current user 
		@follower_relationships = Relationship.where("relationships.followed_id = :current_user_id AND 
																									relationships.confirmed = true ", current_user_id: current_user.id)
		#people who want to view current user
		@view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
											 									 relationships.confirmed = false ", current_user_id: current_user.id)
		#people current user is viewing
		@followed_user_relationships = Relationship.where("relationships.follower_id = :current_user_id",
																											 current_user_id: current_user.id)


    if params[:search]
      @users = User.search params[:search]
      respond_to do |f|
        f.js { render "user_search_results" }
      end
    end
  end

  def invite
    @graph = session[:graph]
    @graph.put_wall_post("I just joined Hoos.in and want to invite you too. ~#{current_user.first_name}", {:name => "Hoos.in", :link => "http://www.hoos.in"}, "#{params[:username]}")
    redirect_to :back
  end

  def find_friends
    @graph = session[:graph]
    @friends = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")

    # @city_friends = @graph.fql_query(
    #   SELECT uid, name, location, pic_square
    #   FROM user 
    #   WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me() AND location = me())
    #   )

    @me = @graph.get_object('me')

    @city_friends = @friends.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
    respond_to do |format|
      format.js
    end
  end


end
