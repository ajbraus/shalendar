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

  def find_friends
    @graph = session[:graph]
    @friendships = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
    # @city_friends = @graph.fql_query(
    #   SELECT uid, name, location, pic_square
    #   FROM user 
    #   WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me() AND location = me())
    #   )
    @me = @graph.get_object('me')
    @invite_friends = []
    @member_friends = []
    @city_friends = @friendships.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
    @city_friends.each do |cf|
      @authentication = Authentication.find_by_uid(cf['id'])
      if @authentication
        @member_friends.push(cf)
      else
        @invite_friends.push(cf)
      end
    end
    respond_to do |format|
      format.html
      #format.js
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
      format.html { redirect_to @event, notice: 'Idea Successfully Shared with Friends' }
    end
  end

  def admin_dashboard
    unless current_user.admin?
      redirect_to root_path
    end

    #USERS
    @total_users = User.all.count
    @new_users_last_week = User.where(['created_at > ?', Time.now - 1.week]).count
    @inactive_users = User.where(['last_sign_in_at < ?', Time.now - 1.month]).count
    @active_users = User.where(['last_sign_in_at > ? AND sign_in_count > 10', Time.now - 1.month]).count
    
    #EVENTS
    @events_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).count
  end

  def fb_invite 
    @invitees = params[:invitees].split(', ')
    @subject = params[:subject]
    @message = params[:message]
    @invitees.each do |username|
      Notifier.fb_invite(username + "@facebook.com", @subject, @message)
    end
    redirect_to root_path, notice: 'Message successfully sent to selected Facebook Friends'
  end


  private

  def set_time_zone
    if current_user
      Time.zone = current_user.time_zone if current_user.time_zone
    end
  end
end
