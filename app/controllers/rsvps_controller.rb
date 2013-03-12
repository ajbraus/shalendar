class RsvpsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:rsvp][:plan_id])

    if params[:rsvp][:inout].to_f == 1
      current_user.rsvp_in!(@event)
    elsif params[:rsvp][:inout].to_f == 0
      current_user.rsvp_out!(@event)
    end

    if params[:rsvp][:inout].to_f == 1
      if @event.has_parent?
        respond_to do |format|
          format.html { redirect_to @event.parent }
          format.js { render template: "rsvps/in" }
        end
      else 
        respond_to do |format|
          format.html { redirect_to @event }
          format.js { render template: "rsvps/in" }
        end
      end

    elsif params[:rsvp][:inout].to_f == 0
      respond_to do |format|
        if @event.has_parent?
          format.html { redirect_to @event.parent }
        else
          format.html { redirect_to @event }
        end
          format.js { render template: "rsvps/out" }
      end
    end
  end

  def destroy
    @rsvp = Rsvp.find(params[:id])
    @event = @rsvp.plan
    @rsvp.destroy
    if @event.instances.any?
      @event.instances.each do |i|
        @rsvps = i.rsvps.where(:guest_id => current_user.id)
        @rsvps.each do |r| 
          r.destroy
        end
      end
    end

    respond_to do |format|
      if @event.has_parent?
        format.html { redirect_to @event.parent }
      else
        format.html { redirect_to @event }
      end
      format.js
    end
  end

  # def mute
  #   @rsvp = Rsvp.find(params[:id])
  #   @rsvp.muted = true
  #   @rsvp.save
  # end

  # def unmute
  #   @rsvp = Rsvp.find(params[:id])
  #   @rsvp.muted = false
  #   @rsvp.save
  # end
end