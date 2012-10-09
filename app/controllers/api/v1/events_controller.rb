class Api::V1::EventsController < ApplicationController
   before_filter :authenticate_user!
   respond_to :json
   
   def user_events_on_date
    #receive call to : hoos.in/user_plans_on_date.json?date="DateInString"
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user
      Time.zone = @mobile_user.time_zone if @mobile_user.time_zone
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
        @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,  
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids
        }
     	@list_events.push(@temp)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @list_events }
    end
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
      render :status => 400, :json => {:success => false}
    else
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
          :guests => @event.guests 
        }
    end
  end

  def mobile_create
    @mobile_user = User.find_by_id(params[:user_id])
    
    if @mobile_user.nil?
      render :status => 400, :json => {:success => false}
      return
    end
    
    @event = current_user.events.build(params[:event])

  end

end