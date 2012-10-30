class Api::V1::EventsController < ApplicationController
   before_filter :authenticate_user!
   respond_to :json
   
   def user_events_on_date
    #receive call to : hoos.in/user_plans_on_date.json?date="DateInString"
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user
      Time.zone = @mobile_user.time_zone if @mobile_user.time_zone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end
    raw_datetime = DateTime.parse(params[:date])

    @events = @mobile_user.mobile_events_on_date(raw_datetime.in_time_zone(@mobile_user.time_zone))#Need to check timezone here
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
        :image => e.promo_img.url(:medium), 
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
    if @mobile_user
      Time.zone = @mobile_user.time_zone if @mobile_user.time_zone
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
          :share_a => @mobile_user.invited_all_friends?(@event)
        }
    end
  end

  def mobile_create
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    @guests_can_invite_friends = false
    if params[:g_share] == '1'
      @guests_can_invite_friends = true
    end
    @min = 1
    unless params[:min] == ""
      @min = Integer(params[:min])
    end
    @max = 100000
    unless params[:max] == ""
      @max = Integer(params[:max])
    end

    @event_params = {
      title: params[:title],
      #chronic_starts_at: DateTime.parse(params[:start]),
      duration: Integer(params[:duration]),
      guests_can_invite_friends: @guests_can_invite_friends,
      min: @min,
      max: @max,
      link: "",
      price: "",
      address: ""
    }

    @event = @mobile_user.events.build(@event_params)
    # @event.user = @mobile_user
    # @event.chronic_starts_at = DateTime.parse(params[:start])
    @event.starts_at = DateTime.parse(params[:start])
    @event.ends_at = @event.starts_at + @event.duration.hours
    # @event.duration = Integer(params[:duration])
    
    # @event.title = params[:title]
    # @event.min = params[:min]
    # @event.max = params[:max]

 
    if @event.save
      @mobile_user.rsvp!(@event)
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
end