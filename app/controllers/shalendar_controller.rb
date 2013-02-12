class ShalendarController < ApplicationController
  before_filter :authenticate_user!, except: [ :home ]

	def home
    if user_signed_in?  
      @ins = Event.where('city_id = ? AND ends_at IS NULL OR (ends_at > ? AND one_time = ?)', @current_city.id, Time.now, true).reject { |i| current_user.out?(i) }
      @ideas = Event.where('city_id = ? AND ends_at IS NULL OR (ends_at > ? AND one_time = ?)', @current_city.id, Time.now, true).reject { |i| current_user.rsvpd?(i) }
      @times = Event.where('city_id = ? AND ends_at > ?', @current_city.id, Time.now).order('starts_at ASC').reject { |i| current_user.out?(i) }
      
      #attempt at getting times friends are rsvpd to
      @times = @times.select do |i|  #select those user is not out of and may be invited to
        if i.parent.present?
          !current_user.out?(i) && (current_user.in?(i) || current_user.in?(i.parent) || i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count > 0) 
        else
          !current_user.out?(i) && (current_user.in?(i) || i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count > 0 )
        end
      end
      @times = @times.reject do |i| #reject all that are friends only and the user isn't in or invited
        if i.parent.present?
          i.friends_only && !current_user.in?(i) && !current_user.in?(i.parent) && !i.user.is_friends_with?(current_user)
        else
          i.friends_only && !current_user.in?(i) && !i.user.is_friends_with?(current_user)
        end
      end
      @ideas = @ideas.reject do |i|
        i.friends_only && !current_user.in?(i) && !i.user.is_friends_with?(current_user)
      end

      @ideas = @ideas.sort_by do |i| 
        i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count*1000 + 
            i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 1, current_user.id).count
      end
      
    else
      @ideas = Event.where('city_id = ? AND ends_at IS NULL OR (ends_at > ? AND one_time = ?) AND friends_only = ?', @current_city.id, Time.now, true, false)
      @times = Event.where('city_id = ? AND ends_at > ? AND friends_only = ?', @current_city.id, Time.now, false).order('starts_at ASC')
    end 
    #show alert if rescue from errors:
    if params[:oofta] == 'true'
      flash.now[:oofta] = "We're sorry, an error occured"
    end
	end

  #HEADER 

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

  def yellow_pages
    @venues = User.where('city = ? AND vendor = ?', @current_city, true)
  end

  def search
    @users = User.search(params[:search]).limit(5)
    respond_to do |format|
      format.js 
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
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => @start_date.to_time }}
      f.series(:name=>'Users', :data => @users_per_week )
      f.xAxis(:type => 'datetime')
    end

    #EVENTS
    @events_last_week = Event.where(:starts_at => Time.now..(Time.now - 1.week)).count
    @events_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).count
    @rsvps_last_week = Rsvp.where(['created_at > ?', Time.now - 1.week])
    @rsvps_next_week = Rsvp.where(['created_at > ?', Time.now + 1.week])
    #need to show 'reach' 
    #@invitations_last_week = Event.where(:starts_at => Time.now..(Time.now - 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }
    #@invitations_next_week = Event.where(:starts_at => Time.now..(Time.now + 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }

    #RSVPs graph
    @rsvps_per_week = []
    @events_per_week = []
    #@invitations_per_week = []
    @ratio_rsvps_to_invitations = [] 
    (0..@weeks).each do |week|
      @start = @start_date + week.weeks
      @end = @start_date + (week + 1).weeks
      @rsvps_one_week = Rsvp.where(:created_at => @start..@end).count
      @rsvps_per_week << @rsvps_one_week

      @events_one_week = Event.where(:created_at => @start..@end).count
      @events_per_week << @events_one_week

      # @invitations_one_week = Invitation.where(:created_at => @start..@end).count
      # @invitations_per_week << @invitations_one_week

      # if @rsvps_one_week > 0 && @invitations_one_week > 0 
      #   @ratio_rsvps_to_invitations << (@rsvps_one_week / @invitations_one_week)
      # else 
        @ratio_rsvps_to_invitations << 0
      # end
    end

    @rsvps_v_events = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:title][:text] = "RSVPs vs. Events Since Inception"
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => @start_date }}
      f.series(:name=>'RSVPs', :data => @rsvps_per_week )
      f.series(:name=>'Events', :data=> @events_per_week )
      f.xAxis(:type => 'datetime')
    end

    # @rsvps_to_invitations = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.options[:title][:text] = "Invitation to Rsvp conversion rate since inception"
    #   f.options[:chart][:defaultSeriesType] = "line"
    #   #f.options[:chart][:width] = 460
    #   #f.options[:chart][:height] = 350
    #   f.options[:yAxis][:min] = 0
    #   f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
    #   f.series(:name=>'Madison', :data => @ratio_rsvps_to_invitations )
    #   f.xAxis(:type => 'datetime')
    # end

    # @invitations = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.options[:title][:text] = "Invitations Since Inception"
    #   f.options[:chart][:defaultSeriesType] = "line"
    #   f.options[:plotOptions] = {:area => { :pointInterval => "#{1.week}", :pointStart => "#{@start_date}" }}
    #   f.series(:name=>'Invitations', :data=> @invitations_per_week)
    #   f.xAxis(:type => 'datetime')
    # end

  end
  private

end
