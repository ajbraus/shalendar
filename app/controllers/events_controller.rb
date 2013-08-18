 class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  require 'active_support/core_ext'

  # GET /events
  # GET /events.json
  def index
    if params[:id]
      @user = User.find(params[:id])
      
      #ONLY SHOW EVENTS THEY ARE BOTH INVITED OR RSVPD TO
      @current_user_invited_ideas = current_user.invited_events.where('city_id = ?', @current_city.id)
      @current_user_invited_times = current_user.instance_invited_events.where('city_id = ?', @current_city.id).map(&:event)
      @current_user_interesteds = current_user.plans.where('city_id = ?', @current_city.id)
      @current_user_ins = current_user.instance_plans.where('city_id = ?', @current_city.id).map(&:event)

      @user_invited_ideas = @user.invited_events.where('city_id = ?', @current_city.id)
      @user_invited_times = @user.instance_invited_events.where('city_id = ?', @current_city.id).map(&:event)
      @user_interesteds = @user.plans.where('city_id = ?', @current_city.id)
      @user_ins = @user.instance_plans.where('city_id = ?', @current_city.id).map(&:event)

      @invited_ideas = (@current_user_invited_ideas & @user_invited_ideas).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
      @invited_times = (@current_user_invited_times & @user_invited_times).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
      @interesteds = (@current_user_interesteds & @user_interesteds).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
      @ins = (@current_user_ins & @user_ins).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
    else
      @user = current_user

      @invited_ideas = @user.invited_events.where('city_id = ?', @current_city.id).paginate(:page => params[:page], :per_page => 10, :order => 'created_at DESC')
      @invited_times = @user.instance_invited_events.where('city_id = ?', @current_city.id).map(&:event).paginate(:page => params[:page], :per_page => 10)
      @interesteds = @user.plans.where('city_id = ?', @current_city.id).paginate(:page => params[:page], :per_page => 10)
      @ins = @user.instance_plans.where('city_id = ?', @current_city.id).map(&:event).paginate(:page => params[:page], :per_page => 10)
    end

    #show alert if rescue from errors:
    if params[:oofta] == 'true'
      flash.now[:oofta] = "We're sorry, an error occured"
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
      format.js # new.js.erb
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @idea = current_user.events.build
    @instance = @idea.instances.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
      format.js # new.js.erb
    end
  end

  def new_time
    @parent = Event.find_by_slug(params[:event_id])
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @event_start_time = @event.start_time
  end

  # POST /events
  # POST /events.json
  def create
    #removing http:// if present
    if params[:event][:link].present?
      params[:event][:link] = params[:event][:link].split("http://")[1]
    end
    
    @event = current_user.events.build(params[:event])
    @event.city = @current_city
    @event.instances.each do |i|
      i.city = @event.city
    end
    
    if @event.save
      current_user.rsvp_in!(@event)
      @event.instances.each { |i| current_user.instance_rsvp_in!(i) } #INVITATION TO ALL INSTANCES
      @event.invited_users.each { |g| self.inmate!(g) } #INMATE EACH GUEST

      @event.save_shortened_url if Rails.env.production?

      #SEND CONTACT TO ALL PPL WHO STAR CURRENT USER
      unless @event.visibility == 0
        @friended_bys = current_user.friended_bys
        @friended_bys.each do |sb|
          unless sb == current_user
            if @instance.present?
              sb.delay.contact_new_idea(@instance)
            else
              sb.delay.contact_new_idea(@event)
            end
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to @event, notice: "Idea Posted Successfully" }
        format.json { render json: @event, status: :created, location: @event }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: "An Error prevented Your Idea from Posting" }
      end
    end
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @event = Event.find(params[:id]) #find the event and eager load its guests as well as its comments and the comments' user association
    @comments = @event.comments.order("created_at desc")

    respond_to do |format|
      format.js
      format.html
      format.json { render json: @event }
      format.ics do
        calendar = Icalendar::Calendar.new
        calendar.add_event(@event.to_ics)
        calendar.publish
        render :text => calendar.to_ical
      end
    end
    #rescue if record not found
    rescue ActiveRecord::RecordNotFound  
    flash[:notice] = "Idea Not Found"
    redirect_to root_path
    return
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    #datetime datepicker => format Chronic can parse
    if params[:event][:chronic_starts_at].present?
      params[:event][:chronic_starts_at] = params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' ')
    end
    params[:event][:starts_at] = Chronic.parse(params[:event][:chronic_starts_at])

    #when updating one_time it was submitting a nil value for this field and it was updating onetime ideas
    if params[:event][:starts_at].blank?
      params[:event].delete(:starts_at)
    end

    if params[:event_id].present?
      params[:id] = params[:event_id]
    end

    @event = Event.find(params[:id])

    @start_time = @event.starts_at
    respond_to do |format|
      if @event.update_attributes(params[:event])
        unless @start_time.blank?
          if @start_time != @event.starts_at
            @event.ends_at = @event.starts_at + @event.duration*3600
            @event.save
            @event.guests.each do |g|
              unless g == @event.user
                g.delay.contact_time_change(@event)
              end
            end
          end
        end

        if @event.has_parent?
          format.html { redirect_to @event.parent, notice: 'Time was successfully updated.' }
        else
          format.html { redirect_to @event, notice: 'Idea was successfully updated.'  }
        end
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
    @event.dead = true
    @event.save

    @event.instances.each do |i|
      i.dead = true
      i.save
      if i.ends_at > Time.zone.now
        i.guests.each do |g|
          g.delay.contact_cancellation(@event)
        end
      end
    end

    if @event.ends_at.present? && @event.ends_at > Time.zone.now
      @event.guests.each do |g|
        g.delay.contact_cancellation(@event)
      end
    end

    respond_to do |format|
      if @event.has_parent?
        format.html { redirect_to @event.parent, notice: 'Time was successfuylly cancelled' }
      else 
        format.html { redirect_to root_path, notice: 'Idea was successfully cancelled' }
      end
      format.json { head :no_content }
    end
  end

  def post_to_own_fb_wall
    @event = Event.find_by_id(params[:event_id])
    if current_user.permits_wall_posts?(session[:graph]) == true
      @uid = current_user.authentications.find_by_provider("Facebook").uid
      @event.post_to_fb_wall(@uid, session[:graph])
      respond_to do |format|
        format.html { redirect_to @event, notice: "Successfully posted event to your facebook wall" }
        format.js
      end 
    else
      respond_to do |format|
        format.html { redirect_to @event, notice: "It was not possible to post this idea to your facebook wall" }
        format.js { render template: "fb_invites/extend_permissions" }
      end 
    end
  end

  # END CLASS
end
