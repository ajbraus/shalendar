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
    # @event = @parent.instances.build(user_id: current_user.id,
    #                            title: @parent.title,
    #                            address: @parent.address,
    #                            link: @parent.link,
    #                            guests_can_invite_friends: @parent.guests_can_invite_friends,
    #                            promo_img: @parent.promo_img,
    #                            promo_url: @parent.promo_url,
    #                            promo_vid: @parent.promo_vid,
    #                            is_public: @parent.is_public,
    #                            family_friendly: @parent.family_friendly,
    #                            price: @parent.price,
    #                            city_id: @parent.city.id
    #                       )
  end

  # GET /events/1/edit
  def edit
    @parent = Event.find(params[:id])
    @event = @parent
    @event_start_time = @parent.start_time
  end

  # POST /events
  # POST /events.json
  def create
    #datetime datepicker => format Chronic can parse
    if params[:event][:chronic_starts_at].present? 
      params[:event][:chronic_starts_at] = params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' ')
    end
    @event = current_user.events.build(params[:event])
    if params[:invite_me] == '1'
      @event.is_public = true
    end
    @event.guests_can_invite_friends = true
    @event.city = @current_city
    @event.tipped = true   if @event.min <= 1
    
    if @event.starts_at.present? && @event.duration.present?
      #SET ENDS_AT IF PRESENT
      @event.ends_at = @event.starts_at + @event.duration*3600
      if params[:event][:one_time] == '0'
        #IF ONGOING EVENT CREATE CHILD INSTANCE
        @instance = @event.instances.build(user_id: current_user.id,
                                 city_id: @event.city.id,
                                 title: @event.title,
                                 starts_at: @event.starts_at,
                                 ends_at: @event.ends_at,
                                 duration: @event.duration,
                                 min: @event.min,
                                 max: @event.max,
                                 address: @event.address,
                                 link: @event.link,
                                 guests_can_invite_friends: @event.guests_can_invite_friends,
                                 promo_img: @event.promo_img,
                                 promo_url: @event.promo_url,
                                 promo_vid: @event.promo_vid,
                                 is_public: @event.is_public,
                                 family_friendly: @event.family_friendly,
                                 price: @event.price
                              )
        if @instance.save
          @instance.save_shortened_url
          current_user.rsvp_in!(@instance)
          if params[:invite_me] == "2" || params[:invite_me] == "1"
            current_user.invite_all_friends!(@instance)
          end
          @instance.tipped = true   if @instance.min <= 1
          
          #CLEAR PARENT EVENT TIME ATTRIBUTES
          @event.starts_at = nil
          @event.ends_at = nil
          @event.duration = nil
        end # END if instance.save
      else #it's a one-time
        @event.one_time = true
      end #END if ongoing event create instance
    end # END If starts_at present

    if @event.save
      current_user.rsvp_in!(@event)
      @event.save_shortened_url
      if params[:category_id]
        Categorization.create(event_id: @event.id, category_id: params[:category_id])
      end
      if params[:invite_me] == '1' || params[:invite_me] == '2'
        current_user.invite_all_friends!(@event)
      end
      
      if @instance.present?
        if @event.categorizations.any?
          Categorization.create(event_id: @instance.id, category_id: @event.categorizations.first.id )
        end
        respond_to do |format|
          format.html { redirect_to @instance, notice: "Idea Posted Successfully" }
          format.json { render json: @instance, status: :created, location: @event }
        end
      else
        respond_to do |format|
          format.html { redirect_to @event, notice: "Idea Posted Successfully" }
          format.json { render json: @event, status: :created, location: @event }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: "An Error prevented Your Idea from Posting" }
      end
    end
  end

  def create_new_time
    #datetime datepicker => format Chronic can parse
    if params[:event][:chronic_starts_at].present? 
      params[:event][:chronic_starts_at] = params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' ')
    end
    params[:event][:starts_at] = Chronic.parse(params[:event][:chronic_starts_at])
    @parent = Event.find_by_id(params[:event][:parent_id])
    @event = @parent.instances.build(user_id: current_user.id,
                           title: @parent.title,
                           starts_at: params[:event][:starts_at],
                           ends_at: params[:event][:starts_at] + params[:event][:duration].to_i*3600,
                           address: params[:event][:address],
                           duration: params[:event][:duration],
                           min: params[:event][:min],
                           link: @parent.link,
                           guests_can_invite_friends: @parent.guests_can_invite_friends,
                           promo_img: @parent.promo_img,
                           promo_url: @parent.promo_url,
                           promo_vid: @parent.promo_vid,
                           family_friendly: @parent.family_friendly,
                           price: @parent.price,
                           city_id: current_user.city.id #users from other cities can poach ideas
                           )
    
    if params[:event][:invite_me] == '1'
      @event.is_public = true
    end
    @event.tipped = true   if @event.min <= 1
    if @event.save
      @event.save_shortened_url
      current_user.rsvp_in!(@event)
      if params[:event][:invite_me] == '1' || params[:event][:invite_me] == '2'
        @rsvp = current_user.rsvps.find_by_plan_id(@event.id)
        current_user.invite_all_friends!(@event)
        @rsvp.invite_all_friends = true
        @rsvp.save
      end
      if @parent.categorizations.any?
        Categorization.create(event_id: @event.id, category_id: @parent.categorizations.first.id )
      end
      @parent.guests.each do |g|
        unless g == @event.user
          g.delay.contact_new_time(@event)
        end
      end
      respond_to do |format|
        format.html { redirect_to @event, notice: "New Time Posted Successfully" }
        format.json { render json: @event, status: :created, location: @event }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: "An Error Prevented A New Time From Posting" }
      end
    end

  end


  #GET /events/id
  #GET /events/id.json
  def show
    @event = Event.find(params[:id])
    @guests = @event.guests
    @email_invites = @event.email_invites
    @invited_users = @event.all_invited_users - @event.guests - @event.unrsvpd_users
    @comments = @event.comments.order("created_at desc")
    if user_signed_in?
      if current_user.authentications.find_by_provider("Facebook").present?
        @graph = session[:graph] 
      else 
        session[:graph] = nil
      end
      #for sidebar
      @my_plans = current_user.plans.where('ends_at > ?', Time.now).order('starts_at asc')

      @friends = current_user.followers.reject { |f| f.invited?(@event) || f.rsvpd?(@event)}
      
      #if a user is 'everywhere else' then we don't silo their invitations...
      @friends = @friends.reject { |f| f.city != @current_city }
      @fb_invites = @event.fb_invites
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
        #datetime datepicker => format Chronic can parse
    params[:event][:starts_at] = Chronic.parse(params[:event][:chronic_starts_at])
    if params[:event][:chronic_starts_at].present?
      params[:event][:chronic_starts_at] = params[:event][:chronic_starts_at].split(/\s/)[1,2].join(' ')
    end

    @event = Event.find(params[:id])
    if params[:parent_id]
      @parent = Event.find_by_id(params[:parent_id])
      @event.parent_id = @parent.id
      if @parent.categorizations.any?
        Categorization.create(event_id: @event.id, category_id: @parent.categorizations.first.id )
      end
    end
    @start_time = @event.starts_at #don't worry about timezone here bc only on server
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
        if @event.guest_count >= @event.min
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
    @event.instances.each do |i|
      i.destroy
    end
    # @event_guests = @event.guests
    # @event.rsvps.each do |r|
    #   r.destroy
    # end
    # @event.invitations.each do |i|
    #   i.destroy
    # end
    @event.contact_cancellation

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
                             is_public: @event.is_public,
                             family_friendly: @event.family_friendly,
                             price: @event.price
                          )
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def get_fb_friends_to_invite
    @invite_friends = current_user.fb_friends(session[:graph])[1].reject { |inf| FbInvite.find_by_uid(inf['uid'].to_s) }
    @event = Event.find(params[:event_id])

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

