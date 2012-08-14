class RsvpsController < ApplicationController
  # before_filter :authenticate_user!

  def create
    @mobile_user = User.find_by_id(3)
    @event = Event.find(params[:rsvp][:plan_id])
    @mobile_user.rsvp!(@event)
    if @event.guests.count == @event.min
      Notifier.event_tipped(@event).deliver
    end
    redirect_to @event

    # respond_to do |format|
    # 	format.html { redirect_to @event }
    # 	format.js
    # end
  end

  def destroy
    @mobile_user = User.find_by_id(3)
    @event = Rsvp.find(params[:id]).plan
    @mobile_user.unrsvp!(@event)
    redirect_to @event

    # respond_to do |format|
    #   format.html { redirect_to @event }
    #   format.js
    # end
  end
end