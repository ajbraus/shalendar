class EventsController < ApplicationController
  before_filter :authenticate_user!

  require 'active_support/core_ext'

  # GET /events
  # GET /events.json
  def index
    @events = Event.scoped
    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = current_user.events.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(params[:event])
    respond_to do |format|
      if @event.save
        current_user.rsvp!(@event)
        if(@event.min <= 1)
          @event.tipped = true
          @event.save
        end
        # if current_user.post_to_fb_wall? && session[:access_token]
        #   @graph = Koala::Facebook::API.new(session[:access_token])
        #   @graph.put_wall_post("#{@event.title}", { :link => "http://www.hoos.in/events/#{@event.id}"}, target_id = 'me')
        # end

        if @event.visibility == "invite_only"
          format.html { redirect_to @event }
          format.json { render json: @event, status: :created, location: @event }
        else
          format.html { redirect_to home_path, notice: "Idea posted! On #{@event.start_time}"}
          format.json { render json: home_path, status: :created, location: @event }
        end
      else
        format.html { redirect_to home_path, notice: "Idea could not be posted." }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
                                         relationships.confirmed = false ", current_user_id: current_user.id)
    @event = Event.find(params[:id])
    @guests = @event.guests
    @json = @event.to_gmaps4rails
    #separating invites by email from invites who are users
    @invites = []
    @invited_users = []
    @event.invites.each do |i|
      if u = User.find_by_email(i.email)
        @invited_users.push(u)
      else
        @invites.push(i)
      end
    end
    @invited_users = @invited_users - @event.guests

    @access_token = session[:access_token]
    @graph = Koala::Facebook::API.new(@access_token)
    @comments = @event.comments.order("created_at desc")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @start_time = @event.starts_at
    @location = @event.lng
    respond_to do |format|
      if @event.update_attributes(params[:event])
        if @start_time != @event.starts_at
          Notifier.time_change(@event).deliver
        elsif @location != @event.lng
          Notifier.location_change(@event).deliver
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

    Notifier.cancellation(@event).deliver

    @event.destroy

    respond_to do |format|
      format.html { redirect_to home_path }
      format.json { head :no_content }
    end
  end

  def tip
    @event = Event.find(params[:event_id])
    @event.tip!
    @event.save
    respond_to do |format|
     format.html { redirect_to :back }
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

