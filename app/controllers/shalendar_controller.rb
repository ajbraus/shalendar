class ShalendarController < ApplicationController
  before_filter :authenticate_user!, except: [ :vendor_splash, :home, :discover, :what_is_hoosin ]

	def home
    if user_signed_in?
      @plan_counts = []
      @invite_counts = []
      @city = current_user.city
      @time_in_zone = Time.now
  		@date = @time_in_zone.to_date
      @events = current_user.forecast(@time_in_zone)
      @my_plans = current_user.plans.where('ends_at > ?', @time_in_zone).order('starts_at asc')
      if current_user.authentications.find_by_provider("Facebook").present?
        @graph = session[:graph] 
      else 
        session[:graph] = nil
      end
      if @graph
        @member_friends = current_user.fb_friends(@graph)[0]
        @friend_suggestions = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }.shuffle.first(3)
      end
    else
      if params[:city].present?
        @city = City.find_by_name(params[:city])
      else
        @city = City.find_by_name("Madison, Wisconsin")
      end

      @time_in_zone = Time.now.in_time_zone(@city.timezone)

      @events = Event.public_forecast(@time_in_zone, @city, session[:toggled_categories])
    end 
    # Beginning of Yellow Pages
    #@vendors = User.where('city = :current_city and vendor = true', current_city: current_user.city)
	end

	def manage_friends
		@graph = session[:graph]
		@friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = current_user.vendor_friendships
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @my_plans = current_user.plans.where('starts_at > ?', Time.now).order('starts_at desc')
    if @graph
      @member_friends = current_user.fb_friends(@graph)[0]
      @friend_suggestions = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }.shuffle.first(3)
    end
    
    #Beginning of Yellow Pages
    #@vendors = User.where('city = :current_city and vendor = true', current_city: current_user.city)
    if params[:search]
      @users = User.search params[:search]
      respond_to do |f|
        f.js { render "user_search_results" }
      end
    end
  end

  def find_friends
    @member_friends = current_user.fb_friends(session[:graph])[0]
    @invite_friends = current_user.fb_friends(session[:graph])[1]
    @me = session[:graph].get_object("me")
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def share_all_fb_friends
    @invite_friends = current_user.fb_friends(session[:graph])[1]
    if Rails.env.production?
      @invite_friends.each do |inf|
      session[:graph].delay.put_connections( inf['uid'], "feed", {
                                      :message => "hoos.in for some fun?", 
                                      :name => "hoos.in",
                                      :link => "http://www.hoos.in/",
                                      :caption => "Do Great Things With Friends",
                                      :picture => "http://www.hoos.in/assets/icon.png"
                                    })
      end
    else
      session[:graph].put_connections( 510890387, "feed", {
                                      :message => "hoos.in for some fun?", 
                                      :name => "hoos.in",
                                      :link => "http://www.hoos.in/",
                                      :caption => "Do Great Things With Friends",
                                      :picture => "http://www.hoos.in/assets/icon.png"
                                    })
    end
    respond_to do |format|
      format.html { redirect_to root_path, notice: ".invited your Facebook friends to hoos.in" }
      format.js
    end
  end

  def friend_all
    @member_friends = current_user.fb_friends(session[:graph])[0] #RETURNS AN ARRAY [[HOOSIN_USERS][NOT_HOOSIN_USERS(FB_USERS)]]
    @member_friends.each do |mf|
      unless current_user.following?(mf) || mf.vendor? || current_user.request_following?(mf)
          current_user.friend!(mf)
      end
    end
    @plan_counts = []
    @invite_counts = []
    @date = Time.now.to_date #in_time_zone("Central Time (US & Canada)")
    @forecastevents = current_user.forecast(Time.now, @plan_counts, @invite_counts)
    @event_suggestions = Suggestion.event_suggestions(current_user)
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = current_user.vendor_friendships   

    respond_to do |format|
      format.html { redirect_to root_path, notice: "you are now friends with your Facebook friends who are .in"}
      format.js
    end
  end

  def discover
    if user_signed_in?
      @my_plans = current_user.plans.where('starts_at > ?', @date).order('starts_at desc')
      @city = current_user.city
    end
    if params[:city].present? || @city.nil?
        @city = City.find_by_name(params[:city])
    else
      @city = City.find_by_name("Madison, Wisconsin")
    end

    @time_in_zone = Time.now
    @date = @time_in_zone.to_date
    if user_signed_in?

      # Example from SO: Tag.joins(:taggings).select('tags.*, count(tag_id) as "tag_count"').group(:tag_id).order(' tag_count desc')
      #Attempt at real AR / SQL query - will be faster if we have lots of crowd ideas
      # @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, current_user.city.id, Time.now)
      #           .joins(:rsvps).select('events.*, count(plan_id) as "plan_count"').group(:plan_id).order(' plan_count desc')
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, current_user.city.id, Time.now).sort_by{ |i| -i.guests.count}
      #@ideas.sort_by { |i| -i.guests.count }
    elsif session[:city]
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, City.find_by_name(session[:city]).id, Time.now).sort_by{ |i| -i.guests.count}
    else
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, City.find_by_name("Madison, Wisconsin").id, Time.now).sort_by{ |i| -i.guests.count}
    end
  end

  def yellow_pages
    @venues = User.where('city = ? AND vendor = ?', current_user.city, true)
  end

  def search
    @users = User.search(params[:search]).limit(5)
    respond_to do |format|
      format.js 
    end
  end

  def new_invited_events
    #@next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
    @time_in_zone = Time.now
    @new_invitations = current_user.invitations.order('created_at desc').limit(20)
    @new_invited_events = []
    @new_invitations.each do |i|
      e = Event.find_by_id(i.invited_event_id)
      unless current_user == e.user && e.ends_at < Time.now
        e.inviter_id = i.inviter_id
      end
      @new_invited_events.push(e)
    end
    @new_events = @new_invited_events.reject { |event| event.ends_at < Time.now }
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
      format.html { redirect_to @event, notice: 'successfully .invited your friends' }
    end
  end

  def what_is_hoosin

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

    @users_per_week = []
    @start_date = User.unscoped.order('created_at asc').first.created_at.to_date
    @today = Date.today
    @weeks = (@today- @start_date).round/7

    @users = User.all
    (0..@weeks).each do |week|
      @user_one_week = @users.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @users_per_week << @user_one_week
    end

    @users_per_week_graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "New Users Per Week Since Inception"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => '#{1.week}', :pointStart => '#{@start_date}' }}
      f.series(:name=>'Users', :data => @users_per_week )
      f.xAxis(:type => 'datetime')
    end
    
    #EVENTS
    @events_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).count
    @rsvps_last_week = Rsvp.where(['created_at > ?', Time.now - 1.week])
    
    #RSVPs graph
    @rsvps_per_week = []
    @rsvps = Rsvp.all
    (0..@weeks).each do |week|
      @rsvps_one_week = Rsvp.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @rsvps_per_week << @rsvps_one_week
    end

    @events_per_week = []
    @events = Event.all
    (0..@weeks).each do |week|
      @events_one_week = Event.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @events_per_week << @events_one_week
    end

    @rsvps_v_events = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "RSVPs vs. Events Last Week"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => '#{1.week}', :pointStart => '#{@start_date}' }}
      f.series(:name=>'RSVPs', :data => @rsvps_per_week )
      f.series(:name=>'Events', :data=> @events_per_week )
      f.xAxis(:type => 'datetime')
    end
    #SUGGESTIONS
  end


  private

end
