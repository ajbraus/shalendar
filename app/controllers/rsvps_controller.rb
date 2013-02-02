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
      #SHOW FRIENDS TO INVITE IN LIGHTBOX
      #@friends = current_user.followers.reject { |f| f.invited?(@event) || f.rsvpd?(@event)}
      #if a user is 'everywhere else' then we don't silo their invitations...
      #@friends = @friends.reject { |f| f.city != @current_city }
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
      if @event.has_parent?
        respond_to do |format|
          format.html { redirect_to @event.parent }
          format.js { render template: "rsvps/out" }
        end
      else
        respond_to do |format|
          format.html { redirect_to @event }
          format.js { render template: "rsvps/out" }
        end
      end
    end
  end

  def destroy
    @rsvp = Rsvp.find(params[:id])
    @event = @rsvp.plan
    @rsvp.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end