class RsvpsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:rsvp][:event_id])
    current_user.rsvp_in!(@event)
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.js { render template: "rsvps/in" }
    end
  end

  def destroy
    @rsvp = Rsvp.find(params[:id])
    @event = @rsvp.event
    @rsvp.destroy
    if @event.instances.any?
      @event.instances.each do |i|
        @instance_rsvps = i.instance_rsvps.where(:user_id => current_user.id)
        @instance_rsvps.each do |r| 
          r.destroy
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end