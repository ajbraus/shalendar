class InstanceOutsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @instance = Event.find(params[:instance_rsvp][:instance_id])
    @event = @instance.event
    current_user.instance_rsvp_in!(@instance)
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @instance_rsvp = InstanceRsvp.find(params[:id])
    @event = @instance_rsvp.instance.event
    @instance_rsvp.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end