class Api::V2::RsvpsController < ApplicationController
 	before_filter :authenticate_user!
  respond_to :json

  def create
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    @inout = params[:inout]
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{ :error => "event was not found."}
    end
    if @inout == '0'
      @mobile_user.rsvp_out!(@event)
    elsif @inout == '1'
      @mobile_user.rsvp_in!(@event)
      #rsvp in to parent idea
    else
      render :json=>{:error => "Trouble with server.. please try again :)"}
    end
    render :json=> { :success => true
          :eid => @event.id,
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
    unless @mobile_user.rsvpd?(@event) == false
      @mobile_user.unrsvp!(@event)
    end
        render :json=> { :success => true,
          :eid => @event.id
        }, :status=>200
  end

  def flake_out
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    @mobile_user.flake_out!(@event)
            render :json=> { :success => true,
                              :eid => @event.id
        }, :status=>200
  end
end