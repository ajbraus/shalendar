class InstancesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    @instance = @event.instances.build(params[:instance])
    @instance.city = @event.city

    respond_to do |format|
      if @instance.save
        current_user.instance_rsvp_in!(@instance)
        format.html { redirect_to @event, notice: "Time Successfully Added" }
        format.js
      else
        format.html { redirect_to @event, notice: "Time could not be added. Try again following this pattern 'next tuesday at 3:30pm'." }
        format.js
      end
    end
  end

  def destroy
    @instance = Instance.find(params[:id])
    @event = @instance.event
    @instance.destroy
    
    respond_to do |format|
      if @instance.save
        format.html { redirect_to @event, notice: "Time Successfully Removed" }
        format.js
      else
        format.html { redirect_to @event, notice: "Time could not be removed" }
        format.js        
      end
    end
  end

end