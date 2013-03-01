 class EventsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => :show

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
    #@event = current_user.events.build

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
    #datetime datepicker => format Chronic can parse
    if params[:event][:chronic_starts_at].present? 
      params[:event][:chronic_starts_at] = params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' ')
    end

    @event = current_user.events.build(params[:event])
    @event.city = @current_city
    
    if @event.starts_at.present? && @event.duration.present?
      @event.ends_at = @event.starts_at + @event.duration*3600
    end
    
    if @event.save
      current_user.rsvp_in!(@event)
      @event.save_shortened_url
      
      if @event.starts_at.present? && @event.duration.present?
        @event.ends_at = @event.starts_at + @event.duration*3600
        if params[:event][:one_time] == '0'
        #IF ONGOING EVENT CREATE CHILD INSTANCE
          @instance = @event.instances.build(user_id: current_user.id,
                                 city_id: @event.city.id,
                                 title: @event.title,
                                 starts_at: @event.starts_at,
                                 ends_at: @event.ends_at,
                                 duration: @event.duration,
                                 address: @event.address,
                                 link: @event.link,
                                 promo_img: @event.promo_img,
                                 promo_url: @event.promo_url,
                                 promo_vid: @event.promo_vid,
                                 friends_only: @event.friends_only,
                                 family_friendly: @event.family_friendly,
                                 price: @event.price
                              )
          if @instance.save
            @instance.save_shortened_url
            current_user.rsvp_in!(@instance)
            
            #CLEAR PARENT EVENT TIME ATTRIBUTES
            @event.starts_at = nil
            @event.ends_at = nil
            @event.duration = nil
            @event.save
          end # END if instance.save
        else #it's a one-time
          @event.one_time = true
        end #END if ongoing event create instance
      end # END If starts_at present

      #SEND CONTACT TO ALL PPL WHO STAR CURRENT USER
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

  def create_new_time
    #datetime datepicker => format Chronic can parse
    params[:event][:starts_at] = Chronic.parse(params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' '))
    @parent = Event.find_by_id(params[:event][:parent_id])
    @event = @parent.instances.build(user_id: current_user.id,
                           title: @parent.title,
                           starts_at: params[:event][:starts_at],
                           ends_at: params[:event][:starts_at] + params[:event][:duration].to_f*3600,
                           address: params[:event][:address],
                           duration: params[:event][:duration],
                           link: @parent.link,
                           promo_img: @parent.promo_img,
                           promo_url: @parent.promo_url,
                           promo_vid: @parent.promo_vid,
                           family_friendly: @parent.family_friendly,
                           price: @parent.price,
                           city_id: @parent.city.id, 
                           friends_only: @parent.friends_only
                           )
    if @event.save
      @event.save_shortened_url
      current_user.rsvp_in!(@event)
      if @parent.guests.any? 
        @parent.guests.each do |g|
          g.delay.contact_new_time(@event)
        end
      end
      respond_to do |format|
        format.html { redirect_to @event.parent, notice: "New Time Posted Successfully" }
        format.json { render json: @event, status: :created, location: @event }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: "An Error Prevented A New Time From Posting" }
      end
    end
  end


  def edit_time
    @event = Event.find_by_slug(params[:event_id])
    @event_start_time = @event.start_time
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @event = Event.includes({ :rsvps => :guest }, {:comments => :user } ).find(params[:id]) #find the event and eager load its guests as well as its comments and the comments' user association
    @guests = @event.guests
    if user_signed_in?
      @guests.sort_by {|g| g.is_friends_with?(current_user) ? 0 : 1 }
    end
    @maybes = @event.maybes
    #@email_invites = @event.email_invites
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

    if params[:event_id].present?
      params[:id] = params[:event_id]
    end

    @event = Event.find(params[:id])

    @start_time = @event.starts_at
    respond_to do |format|
      if @event.update_attributes(params[:event])
        unless @event.starts_at.nil?
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
