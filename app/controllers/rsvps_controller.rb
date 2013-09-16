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
        @instance_rsvps = i.rsvps.where(:user_id => current_user.id, rsvpable_type: "Instance")
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

  private

  def load_rsvpable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
  end

  def find_rsvpable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
end