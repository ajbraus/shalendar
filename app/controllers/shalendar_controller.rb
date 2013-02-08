class ShalendarController < ApplicationController
  before_filter :authenticate_user!, except: [ :home ]

	def home
    if user_signed_in?  
      @ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?)', Time.now, true).reject { |i| current_user.out?(i) }
      @times = Event.where('ends_at > ?', Time.now).order('starts_at DESC').reject { |i| current_user.out?(i) }

      #@in_ideas =  @ideas.select { |i| current_user.in?(i) || current_user.in?(i.parent) }
      #@invite_ideas = @ideas.select { |i| !current_user.rsvpd?(i) }

      #@in_times = @times.select { |i| current_user.in?(i) || current_user.in?(i.parent) }
      #@invite_times = @times.select { |i| !current_user.rsvpd?(i) }
 
      # @city_ideas = Event.where('(ends_at IS NULL OR (ends_at > ? AND one_time = ?)) AND is_public = ? AND city_id = ?', Time.now, true, true, @current_city.id).reject{|e| current_user.out?(e)}
      # @invites = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?)', Time.now, true)
      #           .joins(:invitations).where(invitations: {invited_user_id: current_user.id}).reject{|e| current_user.out?(e)}
      # @ins = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?)', Time.now, true)
      #             .joins(:rsvps).where(rsvps: {guest_id: current_user.id, inout: 1}).reject{|e| current_user.out?(e)}
      # @mine = Event.where('(ends_at IS NULL OR (ends_at > ? AND one_time = ?)) AND user_id = ?', Time.now, true, current_user.id).reject{|e| current_user.out?(e)}
      
      # @ideas = ( @city_ideas | @ins | @invites | @mine ).shuffle

      # @city_times = Event.where('ends_at > ? AND is_public = ? AND city_id = ?', Time.now - 3.days, true, @current_city.id).order('starts_at DESC')
      # @invites_times = Event.where('ends_at > ?', Time.now - 3.days)
      #           .joins(:invitations).where(invitations: {invited_user_id: current_user.id}).order("starts_at DESC")
      # @ins_times = Event.where('ends_at > ?', Time.now - 3.days)
      #             .joins(:rsvps).where(rsvps: {guest_id: current_user.id, inout: 1}).order('starts_at DESC')
      # @my_times = Event.where('ends_at > ? AND user_id = ?', Time.now - 3.days, current_user.id).order('starts_at DESC')

      # @times = ( @city_times | @ins_times | @invites_times | @my_times ).reject{ |e| current_user.out?(e) || e.is_parent? || (e.starts_at.present? && e.starts_at > Time.now + 26.days) }

      # if @graph.present?
      #   @member_friends = current_user.fb_friends(@graph)[0]
      #   @suggested_friends = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }.shuffle.first(5)
        
        # @fu_events = Event.where(starts_at: Time.now.midnight - 2.weeks .. Time.now.midnight)
        # if @fu_events.any?
        # @fu_events.each do |fue|
        #   @fu_recipients = fue.guests.select{ |g| g.follow_up? }
        #   @fu_recipients.each do |fur|
        #     @new_friends = []
        #     fue.guests.each do |g|
        #       if !fur.following?(g) && fur != g
        #         @new_friends.push(g)
        #       end
        #     end
        #     if @new_friends.any?
        #       Notifier.delay.follow_up(fur, fue, @new_friends)
        #     end
        #   end
        # end
      # end
    else
      #if not signed in display city ideas
      #@ideas = Event.where('(ends_at IS NULL OR (ends_at > ? AND one_time = ?)) AND is_public = ?', Time.now, true, true).order("RANDOM()")
      # @ideas = Event.where('ends_at = ? OR (ends_at > ? AND one_time = ?) AND is_public = ?', nil, Time.now, true, true).order('created_at DESC')
      #@times =  Event.where('ends_at > ? AND is_public = ?', Time.now - 3.days, true).order('created_at DESC')
    end 
    @currently_ideas = true
    # Beginning of Yellow Pages
    #@vendors = User.where('city = :current_city and vendor = true', current_city: @current_city)
    if params[:oofta] == 'true'
      flash.now[:oofta] = "We're sorry, an error occured"
    end
	end

  def calendar
    if user_signed_in?
      @city_times = Event.where('ends_at > ? AND is_public = ? AND city_id = ?', Time.now - 3.days, true, @current_city.id).order('created_at DESC')
      @invites = current_user.invited_events.where('ends_at > ? ', Time.now)
      @ins = Event.where('ends_at > ?', Time.now)
                  .joins(:rsvps).where(rsvps: {guest_id: current_user.id, inout: 1}).order('created_at DESC')
      @mine = Event.where('ends_at > ? AND user_id = ?', Time.now, current_user.id).order('created_at DESC')
      @times = ( @city_times | @ins | @invites | @mine ).reject{|e| current_user.out?(e)}
    else
      @times =  Event.where('ends_at > ? AND is_public = ? AND city_id = ?', Time.now - 3.days, true, @current_city.id).order('created_at DESC')
    end
  end

  #HEADER 
  
  def new_invited_events
    @invites = current_user.relevant_invites
    current_user.new_invited_events_count = 0
    current_user.save
    respond_to do |format|
      format.js 
    end
  end

  def plans
    @ideas = current_user.plans.where('ends_at > ?', Time.now).order('starts_at asc')
    respond_to do |format|
      format.html
      format.js
    end
  end

  def ins
    @ideas = current_user.plans
  end

  def friends_ideas
    @ideas = current_user.relevant_invites
  end

  def city_ideas
    #@ideas = @current_city.events.select { |e| e.is_public? && e.is_next_instance? }.shuffle
    # @ideas = Event.where(starts_at: @time_range, is_public: true, city_id: @current_city.id).joins(:rsvps).where(rsvps: {'NOT (guest_id = ? AND inout = ?)', current_user.id, 1}).order("starts_at ASC"))

    #or .sort_by{|i| -i.guest_count}
  end

  def my_ideas
    #SHOWS MY IDEAS WITH NO TIMES OR NEXT FUTURE INSTANCE BY ORDER OF CREATED AT
    @ideas = current_user.events.order('created_at desc').select { |e| e.is_next_instance? }
  end



	def manage_friends
		@friendships = current_user.reverse_relationships.select { |r| current_user.is_friends_with?(User.find_by_id(r.follower_id)) } #reverse_relationships.where('relationships.confirmed = true')
    @vendor_friendships = current_user.vendor_friendships
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @my_plans = current_user.plans.where('ends_at > ?', Time.now).order('starts_at asc')
    if @graph.present?
      @member_friends = current_user.fb_friends(@graph)[0]
      @friend_suggestions = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }.shuffle.first(5)
    end
    #Beginning of Yellow Pages
    #@vendors = User.where('city = :current_city and vendor = true', current_city: @current_city)
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
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')  

    respond_to do |format|
      format.html { redirect_to root_path, notice: "you are now friends with your Facebook friends who are .in"}
      format.js
    end
  end

  def crowd_ideas
    if user_signed_in?
      @my_plans = current_user.plans.where('starts_at > ?', @date).order('starts_at desc')

      # Example from SO: Tag.joins(:taggings).select('tags.*, count(tag_id) as "tag_count"').group(:tag_id).order(' tag_count desc')
      #Attempt at real AR / SQL query - will be faster if we have lots of crowd ideas
      # @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, @current_city.id, Time.now)
      #           .joins(:rsvps).select('events.*, count(plan_id) as "plan_count"').group(:plan_id).order(' plan_count desc')
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, @current_city.id, Time.now).sort_by{ |i| -i.guest_count}
      #@ideas.sort_by { |i| -i.guest_count }
    elsif session[:city]
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, City.find_by_name(session[:city]).id, Time.now).sort_by{ |i| -i.guest_count}
    else
      @ideas = Event.where('is_big_idea = ? AND city_id = ? AND starts_at > ?', true, City.find_by_name("Madison, Wisconsin").id, Time.now).sort_by{ |i| -i.guest_count}
    end
  end

  def yellow_pages
    @venues = User.where('city = ? AND vendor = ?', @current_city, true)
  end

  def search
    @users = User.search(params[:search]).limit(5)
    respond_to do |format|
      format.js 
    end
  end
  
  def invite_all_friends
    @event = Event.find_by_id(params[:event_id])
    if @event.has_parent?
      @event = @event.parent
    end
    current_user.invite_all_friends!(@event)
    respond_to do |format|
      format.js 
      format.html { redirect_to @event, notice: 'successfully .invited your friends' }
    end
  end

  def admin_dashboard
    unless current_user.admin?
      redirect_to root_path
    end

    #USERS
    @total_users = User.all.count
    @iphone_users = User.where(:iPhone_user => true).count
    @android_users = User.where(:android_user => true).count
    @desktop_users = User.where(:android_user => false, :iPhone_user => false).count
    
    @devices_pie = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "Mobile Users"
      f.options[:chart][:defaultSeriesType] = "pie"
      series = {
               :type=> 'pie',
               :name=> 'Mobile Users',
               :data=> [
                  ['Desktop',   (@desktop_users/@total_users) ],
                  ['Andorid',       (@android_users/@total_users) ],
                  {
                     :name=> 'iPhone',    
                     :y=> (@iphone_users/@total_users),
                     :sliced=> true,
                     :selected=> true
                  }
               ]
              }
      f.series(series)
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"white",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        } 
        })
    end

    @new_users_last_week = User.where(['created_at > ?', Time.now - 1.week]).count
    @inactive_users = User.where(['last_sign_in_at < ?', Time.now - 1.month])
    @active_users = User.where(['last_sign_in_at > ? AND sign_in_count > 10', Time.now - 2.weeks]).count

    @start_date = User.unscoped.order('created_at asc').first.created_at.to_date
    @today = Date.today
    @weeks = (@today - @start_date).round/7
    @users_per_week = []
    (0..@weeks).each do |week|
      @user_one_week = User.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @users_per_week << @user_one_week
    end

    @users_per_week_graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "New Users Per Week Since Inception"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
      f.series(:name=>'Users', :data => @users_per_week )
      f.xAxis(:type => 'datetime')
    end

    #EVENTS
    @events_last_week = Event.where(:starts_at => Time.now..(Time.now - 1.week)).count
    @events_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).count
    @rsvps_last_week = Rsvp.where(['created_at > ?', Time.now - 1.week])
    @rsvps_next_week = Rsvp.where(['created_at > ?', Time.now + 1.week])
    @invitations_last_week = Event.where(:starts_at => Time.now..(Time.now - 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }
    @invitations_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }

    #RSVPs graph
    @rsvps_per_week = []
    @events_per_week = []
    @invitations_per_week = []
    @ratio_rsvps_to_invitations = [] 
    (0..@weeks).each do |week|
      @start = @start_date + week.weeks
      @end = @start_date + (week + 1).weeks
      @rsvps_one_week = Rsvp.where(:created_at => @start..@end).count
      @rsvps_per_week << @rsvps_one_week

      @events_one_week = Event.where(:created_at => @start..@end).count
      @events_per_week << @events_one_week

      @invitations_one_week = Invitation.where(:created_at => @start..@end).count
      @invitations_per_week << @invitations_one_week

      if @invitations_one_week > 0 && @rsvps_one_week > 0
        @ratio_rsvps_to_invitations << (@rsvps_one_week / @invitations_one_week)
      else 
        @ratio_rsvps_to_invitations << 0
      end
    end

    @rsvps_v_events = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "RSVPs vs. Events Since Inception"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
      f.series(:name=>'RSVPs', :data => @rsvps_per_week )
      f.series(:name=>'Events', :data=> @events_per_week )
      f.xAxis(:type => 'datetime')
    end

    @rsvps_to_invitations = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "Invitation to Rsvp conversion rate since inception"
      f.options[:chart][:defaultSeriesType] = "line"
      #f.options[:chart][:width] = 460
      #f.options[:chart][:height] = 350
      f.options[:yAxis][:min] = 0
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
      f.series(:name=>'Madison', :data => @ratio_rsvps_to_invitations )
      f.xAxis(:type => 'datetime')
    end

    @invitations = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "Invitations Since Inception"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
      f.series(:name=>'Invitations', :data=> @invitations_per_week)
      f.xAxis(:type => 'datetime')
    end

    #PUBLIC IDEAS
    @madison_public_ideas_per_week = [] 
    (0..@weeks).each do |week|
      @public_events = City.find_by_name("Madison, Wisconsin").events.where(:is_public => true)
      @events_one_week = @public_events.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @madison_public_ideas_per_week << @events_one_week
    end

    @other_city_public_ideas_per_week = [] 
    (0..@weeks).each do |week|
      @public_events = Event.where(:is_public => true).reject { |e| e.city_id == City.find_by_name("Madison, Wisconsin").id }
      @events_one_week = @public_events.select { |u| u.created_at.between?(@start_date + week.weeks, @start_date + (week + 1).weeks) }.count
      @madison_public_ideas_per_week << @events_one_week
    end

    @public_ideas_per_city = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "Public Ideas since inception by city"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
      f.series(:name=>'Madison', :data => @madison_public_ideas_per_week )
      f.series(:name=>'Other', :data=> @other_city_public_ideas_per_week )
      f.xAxis(:type => 'datetime')
    end
  end
  private

end
