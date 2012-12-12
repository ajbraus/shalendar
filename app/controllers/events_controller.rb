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
    @event = current_user.events.build
    respond_to do |format|
      format.html # new.html.erb
      #format.json { render json: @event }
      format.js # new.js.erb
    end
  end

  def new_crowd_idea

    respond_to do |format|
      format.html # new.html.erb
      #format.json { render json: @event }
      format.js
    end
  end

  # def update_idea_in_form
  #   @event = current_user.events.build(params[:event])

  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @event_start_time = @event.start_time
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(params[:event])
    if @event.starts_at.present? && @event.duration.present?
      @event.ends_at = @event.starts_at + @event.duration*3600
    end
    @event.tipped = true                    if @event.min <= 1
    @event.parent_id = params[:parent_id]   if params[:parent_id]
    @event.city = current_user.city
    if @event.save
      @event.save_shortened_url
      if params[:category]
        Categorization.create(event_id: @event.id, category_id: params[:category])
      end
      if params[:parent_id]
        if @event.require_payment? && current_user.credit_card_uri.nil?
          redirect_to confirm_payment_path(@event)
        elsif @event.require_payment? && !current_user.credit_card_uri.nil?
          current_user.debit!(@event.price)
          current_user.rsvp!(@event)
        else
          current_user.rsvp!(@event)       
        end
      else
        current_user.rsvp!(@event)
      end
      if params[:invite_all_friends] == "on"
        @rsvp = current_user.rsvps.find_by_plan_id(@event.id)
        current_user.invite_all_friends!(@event)
        @rsvp.invite_all_friends = true
        @rsvp.save
      end 
      if current_user.post_to_fb_wall? && session[:graph] && params[:invite_all_friends] == "on" && @event.guests_can_invite_friends? && Rails.env.production?
        session[:graph].put_wall_post("are you .in for: ", { :name => "#{@event.title}", 
                                            :link => "http://www.hoos.in/events/#{@event.id}", 
                                            :picture => "http://www.hoos.in/assets/icon.png",
                                            })
      end
      respond_to do |format|
        format.html { redirect_to @event, notice: "Idea Posted Successfully" }
        format.json { render json: @event, status: :created, location: @event }
      end
    elsif @event.is_big_idea?
      respond_to do |format|
        format.html { redirect_to discover_path, notice: "An Error prevented Your Idea from Posting" }
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
    @event = Event.find(params[:id])
    @guests = @event.guests
    @email_invites = @event.email_invites
    @invited_users = @event.invited_users - @event.guests 
    @comments = @event.comments.order("created_at desc")
    if user_signed_in?
      if current_user.authentications.find_by_provider("Facebook").present?
        @graph = session[:graph] 
      else 
        session[:graph] = nil
      end
      @friends = current_user.followers.reject { |f| f.invited?(@event) || f.rsvpd?(@event)}
      #if a user is 'everywhere else' then we don't silo their invitations...
      @friends = @friends.reject { |f| f.city != current_user.city }

      if @graph
        @invite_friends = current_user.fb_friends(session[:graph])[1].reject { |inf| FbInvite.find_by_uid(inf['uid'].to_s) }
        @fb_invites = @event.fb_invites
      else
        #to fix so that these exist in the calls.
        @invite_friends = []
        @fb_invites = []
      end
    end
    
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
    @event = Event.find(params[:id])
    @start_time = @event.starts_at #don't worry about timezone here bc only on server
    respond_to do |format|
      if @event.update_attributes(params[:event])
        if @start_time != @event.starts_at
          ##NEED TO FIX RESQUE
          @event.ends_at = @event.starts_at + duration*3600
          @event.save
          @event.guests.each do |g|
            unless g == @event.user
              Notifier.delay.time_change(@event, g)
            end
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
    @event_guests = @event.guests
    Notifier.delay.cancellation(@event, @event_guests)
    @event.rsvps.each do |r|
      r.destroy
    end
    @event.invitations.each do |i|
      i.destroy
    end

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Idea was successfully removed' }
      format.json { head :no_content }
    end
  end

  def tip
    @event = Event.find(params[:event_id])
    @event.tip!

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Idea tipped!' }
      format.json { head :no_content }
      format.js
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

  def make_a_group
    @event = Event.find_by_id(params[:event_id])
    @user = current_user
    @group = @event.groups.build(user_id: current_user.id,
                             title: @event.title,
                             starts_at: @event.starts_at,
                             duration: @event.duration,
                             max: @event.max,
                             address: @event.address,
                             link: @event.link,
                             guests_can_invite_friends: true,
                             promo_img: @event.promo_img,
                             promo_url: @event.promo_url,
                             promo_vid: @event.promo_vid,
                             is_public: false,
                             category: @event.category,
                             family_friendly: @event.family_friendly,
                             price: @event.price
                          )
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def repeat
    @event = Event.find_by_id(params[:event_id])
    @user = current_user
    @new_event = @user.events.build(
                             title: @event.title,
                             starts_at: '',
                             duration: @event.duration,
                             min: @event.min,
                             max: @event.max,
                             address: @event.address,
                             link: @event.link,
                             guests_can_invite_friends: @event.guests_can_invite_friends,
                             promo_img: @event.promo_img,
                             promo_url: @event.promo_url,
                             promo_vid: @event.promo_vid,
                             is_public: false,
                             category: @event.category,
                             family_friendly: @event.family_friendly,
                             price: @event.price
                          )
    respond_to do |format|
      #format.html
      format.js
    end
  end

  # END CLASS
end


  # TO PRUNE DATABASE
  # def clean_up
  #   @event = Event.find(params[:id])

  #   @event.destroy

  #   respond_to do |format|
  #     format.html { redirect_to root_path }
  #     format.json { head :no_content }
  #   end
  # end

