class Api::V1::RsvpsController < ApplicationController
 	before_filter :authenticate_user!

  def create
    @event = Event.find_by_id(params[:event_id])
    @user = User.find_by_id(params[:user_id])
    @user.rsvp!(@event)
    if @event.guests.count == @event.min
      Notifier.event_tipped(@event).deliver
    end
    render :json=> {:success=>true}, :status=>201
  end

  def destroy
    @event = Event.find_by_id(params[:plan_id])
    @user = User.find_by_id(params[:user_id])
    @user.unrsvp!(@event)
    render :json=>{:success => true}, :status =>201

    # respond_to do |format|
    #   format.html { redirect_to @event }
    #   format.js
    # end
  end
end