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
    @member_friends = current_user.fb_friends(session[:graph])[0]
    @friend_suggestions = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }.first(3)
    #@vendors = User.where('city = :current_city and vendor = true', current_city: current_user.city)
	end

	def manage_friends
		@graph = session[:graph]
		@friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = current_user.vendor_friendships
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
      session[:graph].delay.put_connections( inf['id'], "feed", {
                                      :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                      :name => "hoos.in",
                                      :link => "http://www.hoos.in/",
                                      :caption => "Do Great Things With Friends",
                                      :picture => "http://www.hoos.in/assets/icon.png"
                                    })
      end
    else
      session[:graph].put_connections( 510890387, "feed", {
                                      :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                      :name => "hoos.in",
                                      :link => "http://www.hoos.in/",
                                      :caption => "Do Great Things With Friends",
                                      :picture => "http://www.hoos.in/assets/icon.png"
                                    })
    end
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Successfully posted invitations to hoos.in to all your facebook Friends" }
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
    @date = Time.now.in_time_zone(current_user.time_zone).to_date #in_time_zone("Central Time (US & Canada)")
    @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
    @event_suggestions = Suggestion.event_suggestions(current_user)
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = current_user.vendor_friendships   

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Successfully Friended all facebook Friends on hoos.in"}
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
      format.html { redirect_to @event, notice: 'Idea Successfully Shared with Friends' }
    end
  end

   def invite_all_fb_friends(event)
    @invite_friends.each do |inf|
      if Rails.env.production?
        @invite_friends.each do |inf|
        session[:graph].delay.put_connections( inf['id'], "feed", {
                                        :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                        :name => "hoos.in",
                                        :link => "http://www.hoos.in/",
                                        :caption => "Do Great Things With Friends",
                                        :picture => "http://www.hoos.in/assets/icon.png"
                                      })
        end
      else
        session[:graph].put_connections( 2232003, "feed", {
                                        :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                        :name => "hoos.in",
                                        :link => "http://www.hoos.in/",
                                        :caption => "Do Great Things With Friends",
                                        :picture => "http://www.hoos.in/assets/icon.png"
                                      })
      end
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
    @rsvps = []
    (0..6).each do |i|
      @rsvps_per_day = Rsvp.find(:all, :conditions => [" created_at between ? AND ?", Time.zone.now.beginning_of_day - i.days, Time.zone.now.end_of_day - i.days]).count
      @rsvps.push(@rsvps_per_day)
    end

    @events = []
    (0..6).each do |e|
      @events_per_day = Event.find(:all, :conditions => ["starts_at between ? AND ?", Time.zone.now.beginning_of_day - e.days, Time.zone.now.end_of_day - e.days]).count
      @events.push(@events_per_day)
    end

    @rsvps_v_events = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "RSVPs vs. Events Last Week"
      f.options[:chart][:defaultSeriesType] = "line"
      #f.options[:plotOptions] = {:area => { :pointInterval => '#{1.day}', :pointStart => '#{7.days.ago}' }}
      f.series(:name=>'RSVPs', :data => @rsvps )
      f.series(:name=>'Events', :data=> @events )
      #f.xAxis(:type => 'datetime')
    end
    #SUGGESTIONS

  end

  private

  def set_time_zone
    if current_user
      Time.zone = current_user.time_zone if current_user.time_zone
    end
  end
end
