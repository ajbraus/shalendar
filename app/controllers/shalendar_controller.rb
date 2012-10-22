class ShalendarController < ApplicationController
  before_filter :authenticate_user!, except: :vendor_splash
  before_filter :set_time_zone

	def home
    @plan_counts = []
    @invite_counts = []
		@date = Time.now.in_time_zone(current_user.time_zone).to_date #in_time_zone("Central Time (US & Canada)")
    @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
    @graph = session[:graph]
    @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
    @event_suggestions = Suggestion.event_suggestions(current_user)
    @all_suggestions = Suggestion.where('starts_at IS NULL').order('created_at DESC')
                   #or Suggestion.join('user').where('city == ?' current_user.city)
    @suggestions = @all_suggestions.reject do |as|
      !current_user.cloned?(as) || !current_user.rsvpd_to_clone?(as)
    end
    #@vendors = User.where('city = :current_city and vendor = true', current_city: current_user.city)
	end

	def manage_follows
		@graph = session[:graph]
		@friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = []
    current_user.relationships.where('relationships.confirmed = true').each do |r|
      if r.followed.vendor?
        @vendor_friendships << r
      end
    end

		#people who want to view current use
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    #@vendors = User.where('city = :current_city and vendor = true', current_city: current_user.city)
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
    binding.remote_pry
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
      #format.html
      format.js
    end
  end

  def city_vendors
    @vendors = User.where('city = current_user_city vendor = true', current_user_city: current_user.city)
  end

  def search
    @users = User.search(params[:search]).limit(5)
    respond_to do |format|
      format.js 
    end
  end

  def new_invited_events
    @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
    @new_invitations = current_user.invitations.order('created_at desc').limit(25)
    @new_invited_events = []
    @new_invitations.each do |i|
      e = Event.find_by_id(i.invited_event_id)
      unless current_user == e.user && e.ends_at < Time.now
        e.inviter_id = i.inviter_id
      end
      @new_invited_events.push(e)
    end
    @new_invited_events = @new_invited_events.reject { |event| event.ends_at < Time.now }.sort_by {|e| e.starts_at }
    @new_events = @new_invited_events.reverse
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
    @inactive_users = User.where(['last_sign_in_at < ?', Time.now - 1.month])
    @active_users = User.where(['last_sign_in_at > ? AND sign_in_count > 10', Time.now - 1.month]).count

    #EVENTS
    @events_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).count
    @rsvps_last_week = Rsvp.where(['created_at > ?', Time.now - 1.week])
    #RSVPs graph
    @rspvs_each_day_last_week = []
    
    (0..6).each do |i|
      @rsvps_per_day = Rsvp.find(:all, :conditions => [" created_at between ? AND ?", Time.zone.now.beginning_of_day - i.days, Time.zone.now.end_of_day - i.days]).count
      @rspvs_each_day_last_week.push(@rsvps_per_day)
    end

    @rsvps_vs_events_last_week_graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.options[:plotOptions] = {area: {pointInterval: 1.day, pointStart: 7.days.ago}}
      f.series(:name=>'RSVPs', :data=> @rsvps_each_day_last_week)
      #f.series(:name=>'Jane', :data=> [1, 3, 4, 3, 3, 5, 4,-46,7,8,8,9,9,0,0,9] )
      f.xAxis(type: :datetime)
    end
    #SUGGESTIONS

  end

  def fb_invite 
    @invitees = params[:invitees].split(', ')
    @subject = params[:subject]
    @message = params[:message] + " -- www.hoos.in"
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
