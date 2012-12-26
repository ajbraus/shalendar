class RsvpsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:rsvp][:plan_id])
    if params[:rsvp][:inout].to_f == 1
      current_user.rsvp_in!(@event)
    elsif params[:rsvp][:inout].to_f == 0
      current_user.rsvp_out!(@event)
    end

    if @event.guest_count == @event.min && @event.tipped? == false
      @event.tip!
    end

    if @event.has_parent?
      current_user.rsvp_in!(@event.parent)
    end

    if params[:rsvp][:inout] == 1
      respond_to do |format|
        format.html { redirect_to @event }
        format.js { render template: "rsvps/in" }
      end
    elsif params[:rsvp][:inout] == 0
      respond_to do |format|
        format.html { redirect_to @event }
        format.js { render template: "rsvps/out" }
      end
    end
  end

  def destroy
    @rsvp = Rsvp.find(params[:id])
    @rsvp.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end