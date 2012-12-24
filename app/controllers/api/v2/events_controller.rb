class Api::V2::EventsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
   
  def invites
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @time_range = Time.now .. Time.now + 1.year
    @invites = Event.where(starts_at: @time_range).joins(:invitations)
                              .where(invitations: {invited_user_id: @mobile_user.id}).order("starts_at ASC")

    @ins = Event.where(starts_at: @time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: @mobile_user.id}).order("starts_at ASC")

    @events = @invites | @ins

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e)
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def city_ideas
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @time_range = Time.now .. Time.now + 1.year
    @city_ideas = Event.where(starts_at: @time_range, city_id: @mobile_user.city.id).order("starts_at ASC")

    @ins = Event.where(starts_at: @time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: @mobile_user.id}).order("starts_at ASC")

    @events = @city_ideas | @ins

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e)
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def ins
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @time_range = Time.now .. Time.now + 1.year
    @events = Event.where(starts_at: @time_range).joins(:rsvps)
                      .where(rsvps: {guest_id: @mobile_user.id}).order("starts_at ASC")

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => true,
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e)
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def user_events_on_date
    #receive call to : hoos.in/user_plans_on_date.json?date="DateInString"
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end
    raw_datetime = DateTime.parse(params[:date])

    @events = @mobile_user.mobile_events_on_date(raw_datetime.in_time_zone(@mobile_user.city.timezone))#Need to check timezone here

    @events = @events.sort_by{|t| t[:starts_at]}
    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e)
      }
     	@list_events.push(@temp)
    end
    render json: @list_events
  end

  def event_details
    #this will give mobile the info about the guests of the event
    #could add invites here, and/or comments
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    end
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
    else
      @g_share = true
      if @event.guests_can_invite_friends.nil? || @event.guests_can_invite_friends == false
        @g_share = false
      end
      @invitedids = []
      @event.invited_users.each do |i|
        @invitedids.push(i.id)
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      render json: { 
          :eid => @event.id,
          :title => @event.title,  
          :start => @event.starts_at,
          :end => @event.ends_at, 
          :gcnt => @event.guests.count,
          :tip => @event.min,  
          :host => @event.user,
          :plan => @mobile_user.rsvpd?(@event),
          :tipped => @event.tipped,
          :guests => @event.guests,
          :iids => @invitedids,
          :g_share => @g_share,
          :comments => @comments,
          :image => @event.image(:medium),
          :url => @event.short_url,
          :share_a => @mobile_user.invited_all_friends?(@event)
        }
    end
  end

  def mobile_create
    logger.info("#{params}")
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    Time.zone = @mobile_user.city.timezone if @mobile_user.city.present?
    @guests_can_invite_friends = false
    if params[:g_share] == '1'
      @guests_can_invite_friends = true
    end
    @min = 1
    unless params[:min] == ""
      @min = Float(params[:min])
    end
    @max = 100000
    unless params[:max] == ""
      @max = Float(params[:max])
    end

    @event_params = {
      title: params[:title],
      #chronic_starts_at: DateTime.parse(params[:start]),
      #duration: Float(params[:duration]),
      guests_can_invite_friends: @guests_can_invite_friends,
      min: @min,
      min: @min,
      max: @max,
      link: "",
      price: "",
      address: "",
      is_public: 0,
      family_friendly: 0,
      promo_url: "",
      promo_vid: ""
    }

    @event = @mobile_user.events.build(@event_params)
    # @event.user = @mobile_user
    # @event.chronic_starts_at = DateTime.parse(params[:start])
    @event.starts_at = DateTime.parse(params[:start])
    @event.duration = Float(params[:duration])
    @event.ends_at = @event.starts_at + @event.duration*3600
    if @mobile_user.city.present?
      @event.city = @mobile_user.city
    else
      @event.city = City.find_by_name("Madison, Wisconsin")
    end
    
    # @event.title = params[:title]
    # @event.min = params[:min]
    # @event.max = params[:max]

 
    if @event.save
      @mobile_user.rsvp!(@event)
      @event.save_shortened_url
      if params[:invite_all_friends] == '1'
        @rsvp = @mobile_user.rsvps.find_by_plan_id(@event.id)
        @mobile_user.invite_all_friends!(@event)
        @rsvp.invite_all_friends = true
        @rsvp.save
      end
      if @event.min <= 1
        @event.tipped = true
        @event.save
      end
      e = @event
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @response = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,  
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e)
      }
      render json: @response
    else
      render :status => 400, :json => {:error => "Idea did not Save"}
    end
  end

  def add_comment
    #could add invites here, and/or comments
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
    elsif @event.nil?
      render :status => 400, :json => {:error => "could not find your event"}
    else
      @message = params[:comment]
      @comment = @event.comments.new
      @comment.user = @mobile_user
      @comment.content = @message
      if @comment.save
        render :status => 200, :json => {:success => true, comment: {msg: @comment.content, name: @comment.user.name, date: @comment.created_at}}
      else
        render :status => 400, :json => {:error => "could not save comment"}
      end
    end
  end

  def cancel_idea

    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{:error => "event was not found."}
    end
    if @mobile_user != @event.user
      render :status=>300, :json=>{:error => "you don't have the authority to cancel this event"}
    end
    @event.delay.contact_cancellation(@event)
        render :json=> { :success => true
        }, :status=>200
  end
  # def add_photo
  #   @mobile_user = User.find_by_id(params[:user_id])
  #   @event = Event.find_by_id(params[:event_id])
  #   if @mobile_user.nil? || @event.nil?
  #     render :status => 400, :json => {:error => "couldn't find event or user"}
  #   end
  #   if @mobile_user.id != @event.user.id
  #     render :status => 400, :json => {:error => "thinks that your user is not the host of the event"}
  #   end

  #   @userfile = params[:userfile]


  #   render :status => 200, :json => {:success => "got here at least"}
  # end
end