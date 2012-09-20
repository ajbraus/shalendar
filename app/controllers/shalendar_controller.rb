class ShalendarController < ApplicationController
  before_filter :authenticate_user!

	def home
    Time.zone
		@date = Time.now.in_time_zone("Central Time (US & Canada)").to_date
    @forecastevents = current_user.forecast(Time.now.to_s)
    @forecastoverview = current_user.forecastoverview
    @relationships = current_user.relationships.where('relationships.confirmed = true')
    @graph = session[:graph]
    @event = Event.new
    @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
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
    @graph.put_wall_post("I just joined hoos.in and want to invite you to join too. ~#{current_user.first_name}", {:name => "Hoos.in", :link => "http://www.hoos.in"}, "#{params[:username]}")
    render :nothing => true
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

  def datepicker 
    @forecastevents = current_user.forecast(params[:date])
    @date = Date.strptime(params[:date], "%Y-%m-%d")
    respond_to do |format|
      format.js
    end
  end

  def search
    @users = User.search(params[:search]).limit(5)
    respond_to do |format|
      format.js 
    end
  end

end
