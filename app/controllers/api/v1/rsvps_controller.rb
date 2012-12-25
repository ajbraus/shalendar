class Api::V1::RsvpsController < ApplicationController
 	before_filter :authenticate_user!
  respond_to :json

  def create
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{ :error => "event was not found."}
    end
    unless @mobile_user.in?(@event)
      @mobile_user.rsvp_in!(@event)
      if @event.guest_count >= @event.min && @event.tipped? == false
        @event.tip!
      end
    end
    render :json=> { :success => true
          # :eid => @event.id,
          # :title => @event.title,  
          # :start => @event.starts_at,
          # :end => @event.ends_at, 
          # :gcnt => @event.guest_count,  
          # :tip => @event.min,  
          # :host => @event.user,
          # :plan => @mobile_user.in?(@event),
          # :tipped => @event.tipped,
          # :guests => @event.guests 
        }, :status=>200
  end

  def destroy
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{:error => "event was not found."}
    end
    unless @mobile_user.in?(@event) == false
      @mobile_user.rsvp_out!(@event)
    end
        render :json=> { :success => true
          # :eid => @event.id,
          # :title => @event.title,  
          # :start => @event.starts_at,
          # :end => @event.ends_at, 
          # :gcnt => @event.guest_count,  
          # :tip => @event.min,  
          # :host => @event.user,
          # :plan => @mobile_user.in?(@event),
          # :tipped => @event.tipped,
          # :guests => @event.guests 
        }, :status=>200
  end
end