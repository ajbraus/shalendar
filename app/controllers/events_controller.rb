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
        if @event.min <= 1
          @event.tipped = true
          @event.save
        end
        if params[:invite_all_friends] == "1"
          current_user.invite_all_friends!(@event)
        end
        

        if current_user.post_to_fb_wall? && session[:graph] && params[:invite_all_friends] == "1" && @event.guests_can_invite_friends? #&& Rails.env.production?
          # @graph = Koala::Facebook::API.new(session[:access_token])
          session[:graph].put_wall_post("Join me on hoos.in for: ", { :name => "#{@event.title}", 
                                              :link => "http://www.hoos.in/events/#{@event.id}", 
                                              :picture => "http://www.hoos.in/assets/icon.png",
                                              })
        end

        format.html { redirect_to @event }
        format.json { render json: @event, status: :created, location: @event }

      else
        format.html { redirect_to home_path, notice: "Idea could not be posted. Please try again." }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @event = Event.find(params[:id])
    @guests = @event.guests
    @json = @event.to_gmaps4rails
    @friends = current_user.followers
    @email_invites = @event.email_invites
    @invited_users = @event.invited_users - @event.guests
    @graph = session[:graph]
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
    @start_time = @event.starts_at #don't worry about timezone here bc only on server
    respond_to do |format|
      if @event.update_attributes(params[:event])
        if @start_time != @event.starts_at
          @event.guests.each do |g|
            Resque.enqueue(MailerCallback, "Notifier", :time_change, @event.id, g.id)
          end
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
      Notifier.cancellation(@event, g).deliver
    end

    @event.destroy

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
      format.json {head :no_content}
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

