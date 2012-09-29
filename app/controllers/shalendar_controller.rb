class ShalendarController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_time_zone
	def home
    @plan_counts = []
    @invite_counts = []
		@date = Time.now.in_time_zone(current_user.time_zone).to_date #in_time_zone("Central Time (US & Canada)")
    @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
    #@forecastoverview = current_user.forecastoverview
    @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')    
    @graph = session[:graph]
    @event = Event.new
    @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
    @toggled_off_ids = current_user.reverse_relationships.where('toggled = false')
	end

	def manage_follows
		@graph = session[:graph]
		@friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
		#people who want to view current user
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
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
    @friendships = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")

    # @city_friends = @graph.fql_query(
    #   SELECT uid, name, location, pic_square
    #   FROM user 
    #   WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me() AND location = me())
    #   )

    @me = @graph.get_object('me')

    @city_friends = @friendships.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
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

  def new_invited_events
    @new_invitations = current_user.invitations.order('created_at desc').limit(15)
    @new_invited_events = []
    @new_invitations.each do |i|
      e = Event.find_by_id(i.invited_event_id)
      unless current_user == e.user
        e.inviter_id = i.inviter_id
        @new_invited_events.push(e)
      end
    end
    current_user.new_invited_events_count = 0
    current_user.save
    respond_to do |format|
      format.js 
    end
  end

  def invite_all_friends
    @event = Event.find_by_id(params[:event_id])
    current_user.invite_all_friends!(@event)
    respond_to do |format|
      format.js 
      format.html { redirect_to root_path, notice: 'Idea Successfully Shared with Friends' }
    end
  end

  private

  def set_time_zone
    if current_user
      Time.zone = current_user.time_zone if current_user.time_zone
    end
  end
end
