class ShalendarController < ApplicationController
  before_filter :authenticate_user!

	def home
		@current_user = current_user
		@relationships = current_user.relationships.where('relationships.confirmed = true')
  	@graph = Koala::Facebook::API.new(session[:access_token])
  	@event = Event.new
    @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
                                         relationships.confirmed = false ", current_user_id: current_user.id)

    if params[:search]
      @users = User.search params[:search]
    end

    if session[:access_token] 
      @graph = Koala::Facebook::API.new(session[:access_token])
      @friends = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
      @me = @graph.get_object('me')

      @city_friends = @friends.select do |friend|
        friend['location'].present? && friend['location']['id'] == @me['location']['id']
      end
    end

    if params[:date] 
      @forecastevents = current_user.forecast(params[:date])
    else
      @forecastevents = current_user.forecast(Date.today)
    end

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

   def user_events_on_date
    #receive call to : calenshare.com/user_plans_on_date.json?date="DateInString"
    raw_datetime = DateTime.parse(params[:date])
    @mobile_user = User.find_by_id(3)
    #@events = current_user.plans_on_date(raw_date)
    @events = @mobile_user.events_on_date(raw_datetime)

    # For Light-weight events sending for list (but need guests to know if RSVPd)
    # @list_events = []
    # @events.each do |e|
    # 	@temp = {
    #    :id => e.id,
    #    :title => e.title,  
    #    :start => e.starts_at,  
    #    :guest_count => e.guests.count,  
    #    :min_to_tip => e.min,  
    #    :host => e.user,
    #    :plan => @mobile_user.rsvpd?(e)
    #  	}
    #  	@list_events.push(@temp)
    # end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end

  end

  def event_details
  	@event = Event.find_by_id(params[:id])

  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event }
    end

  end

  def user_plans_on_date
    #receive call to : calenshare.com/user_plans_on_date.json?date="DateInString"
    raw_datetime = DateTime.parse(params[:date])
    @mobile_user = User.find_by_id(3)
    #@events = current_user.plans_on_date(raw_date)
    @events = @mobile_user.plans_on_date(raw_datetime)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end

  end

  def user_ideas_on_date
    #receive call to : calenshare.com/user_ideas_on_date.json?date="DateInString"
    raw_datetime = DateTime.parse(params[:date])
    @mobile_user = User.find_by_id(3)
    #@events = current_user.plans_on_date(raw_date)
    @events = @mobile_user.ideas_on_date(raw_datetime)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
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
	 
    if params[:search]
      @users = User.search params[:search]
    end
  end

  def invite
    @graph = Koala::Facebook::API.new(session[:access_token])
    @graph.put_wall_post("I just joined Hoos.in and want to invite you too. ~#{current_user.first_name}", {:name => "Hoos.in", :link => "http://www.hoos.in"}, "#{params[:username]}")
    redirect_to :back
  end

end
