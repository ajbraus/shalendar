class Api::V1::RsvpsController < ApplicationController
 	before_filter :authenticate_user!
  respond_to :json

  def create
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    unless @mobile_user.rsvpd?(@event)
      @mobile_user.rsvp!(@event)
      if @event.guests.count >= @event.min && @event.tipped? == false
        @event.tip!
      end
    end
    render :json=> { 
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
        }, :status=>200
  end

  def destroy
    @event = Event.find_by_id(params[:plan_id])
    @mobile_user = User.find_by_id(params[:user_id])
    unless @mobile_user.rsvpd?(@event) == false
      @mobile_user.unrsvp!(@event)
    end
        render :json=> { 
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
        }, :status=>200
  end
end