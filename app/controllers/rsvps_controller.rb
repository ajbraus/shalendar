class RsvpsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:rsvp][:plan_id])
    current_user.rsvp!(@event)
    if @event.guests.count == @event.min
      Notifier.event_tipped(@event).deliver
    end
    redirect_to @event

    # respond_to do |format|
    #   format.html { redirect_to @event }
    #   format.js
    # end
  end

  def destroy
    @event = Rsvp.find(params[:id]).plan
    current_user.unrsvp!(@event)
    redirect_to @event

    # respond_to do |format|
    #   format.html { redirect_to @event }
    #   format.js
    # end
  end
end