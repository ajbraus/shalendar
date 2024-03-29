class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [ :city_names ]

  def get_intros
    @user = User.includes(:relationships).find_by_slug(params[:id])
    @user_friends = @user.friends.where(city_id: @current_city.id)
    @user_inmates = @user.inmates.where(city_id: @current_city.id)
  end

  def pick_city
    @user = current_user
  end

    # PUT /libraries/1.json
  def update
    @user = current_user

    @city = City.find_by_name(params[:city_name])
    params[:user] = {:city => @city}
    if @city.blank?
      return redirect_to pick_city_path, notice: "City not found. Please choose a city from the autocomplete list closest to you."
    end
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        if @user.fb_user?
          @user.add_fb_events(@graph)
        end
        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def city_names
    @city_names = City.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @city_names.map(&:name)
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

    @new_users_last_week = User.where(['created_at > ?', Time.zone.now - 1.week]).count
    @inactive_users = User.where(['last_sign_in_at < ?', Time.zone.now - 1.month])
    @active_users = User.where(['last_sign_in_at > ? AND sign_in_count > 10', Time.zone.now - 2.weeks]).count

    @start_date = User.unscoped.order('created_at asc').first.created_at.to_date
    @today = Date.current
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
    @events_last_week = Event.where(:starts_at => Time.zone.now..(Time.zone.now - 1.week)).count
    @events_next_week = Event.where(:starts_at => Time.zone.now..(Time.zone.now + 1.week)).count
    @rsvps_last_week = Rsvp.where(['created_at > ?', Time.zone.now - 1.week])
    @rsvps_next_week = Rsvp.where(['created_at > ?', Time.zone.now + 1.week])
    #need to show 'reach' 
    #@invitations_last_week = Event.where(:starts_at => Time.zone.now..(Time.zone.now - 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }
    #@invitations_next_week = Event.where(:starts_at => Time.zone.now..(Time.zone.now + 1.week)).reduce(0) { |sum,e| sum + e.invitations.count }

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
end
