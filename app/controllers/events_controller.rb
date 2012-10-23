class EventsController < ApplicationController
  before_filter :authenticate_user!
  #skip_before_filter :authenticate_user!, :only => :show

  require 'active_support/core_ext'

  # GET /events
  # GET /events.json
  def index
    unless current_user.admin?
      redirect_to root_path
    end

    @events = Event.scoped
    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = current_user.events.build
    respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @event }
      format.js
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @event_start_time = @event.start_time
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(params[:event])

    respond_to do |format|
      if @event.save
        current_user.rsvp!(@event)
        if params[:invite_all_friends] == "on"
          @rsvp = current_user.rsvps.find_by_plan_id(@event.id)
          current_user.invite_all_friends!(@event)
          @rsvp.invite_all_friends = true
          @rsvp.save
        end
        if @event.min <= 1
          @event.tipped = true
          @event.save
        end        
        if current_user.post_to_fb_wall? && !session[:graph].nil? && params[:invite_all_friends] == "on" && @event.guests_can_invite_friends? #&& Rails.env.production?
          # session[:graph].put_wall_post("Join me on hoos.in for: ", { :name => "#{@event.title}", 
          #                                     :link => "http://www.hoos.in/events/#{@event.id}", 
          #                                     :picture => "http://www.hoos.in/assets/icon.png",
          #                                     })
        end
        if params[:invite_all_friends] == "on"
          format.html { redirect_to root_path, notice: "Idea Posted Successfully" }
          format.json { render json: @event, status: :created, location: @event }
        else
        format.html { redirect_to @event, notice: "Idea Posted Successfully" }
        format.json { render json: @event, status: :created, location: @event }
        end
      else
        format.html { redirect_to @event, notice: "Idea could not be posted. Please try again." }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @event = Event.find(params[:id])
    @guests = @event.guests
    @friends = current_user.followers
    @email_invites = @event.email_invites
    @invited_users = @event.invited_users - @event.guests
    @graph = session[:graph]
    @comments = @event.comments.order("created_at desc")
    @invite_friends = []

    if session[:graph]
      @graph = session[:graph]
      @friendships = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
      # @city_friends = @graph.fql_query(
      #   SELECT uid, name, location, pic_square
      #   FROM user 
      #   WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me() AND location = me())
      #   )
      @me = @graph.get_object('me')
      @city_friends = @friendships.select { |friend| friend['location'].present? && friend['location']['id'] == @me['location']['id'] }
      @city_friends.each do |cf|
        @authentication = Authentication.find_by_uid(cf['id'])
        unless @authentication
          @invite_friends.push(cf)
        end
      end
    end
    # Need multi-query to get stuff by location
    # @friendships = @graph.get_connections('me','friends',:fields => "name,picture,location,id,username")
    # @my_city = @graph.fql_query('select current_location from user  where uid=me()')
    # @city_friends = @graph.fql_query('SELECT uid, name, pic_square FROM user WHERE uid IN (SELECT uid2, current_location FROM friend WHERE uid1 = me())')
    # SELECT uid, name, pic_square FROM user WHERE is_app_user AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
    # SELECT current_location, name FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) and "New York" in current_location
    respond_to do |format|
      format.html 
      format.json { render json: @event }
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @start_time = @event.starts_at #don't worry about timezone here bc only on server
    respond_to do |format|
      if @event.update_attributes(params[:event])
        if @start_time != @event.starts_at
          ##NEED TO FIX RESQUE
          @event.guests.each do |g|
            Notifier.delay.time_change(@event, g)
            #Resque.enqueue(MailerCallback, "Notifier", :time_change, @event.id, g.id)
          end
        end
        if @event.guests.count >= @event.min
          @event.tip!
        end
        format.html { redirect_to @event, notice: 'Idea was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.guests.each do |g|
      Notifier.delay.cancellation(@event, g)
    end
    #@event.destroy

    respond_to do |format|
      format.html { redirect_to home_path, notice: 'Idea was successfully removed' }
      format.json { head :no_content }
    end
  end

  def tip
    @event = Event.find(params[:event_id])
    @event.tip!

    respond_to do |format|
      format.html { redirect_to home_path, notice: 'Idea tipped!' }
      format.json { head :no_content }
      format.js
    end
  end

end


  # TO PRUNE DATABASE
  # def clean_up
  #   @event = Event.find(params[:id])

  #   @event.destroy

  #   respond_to do |format|
  #     format.html { redirect_to home_path }
  #     format.json { head :no_content }
  #   end
  # end

