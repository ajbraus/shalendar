class OutsController < ApplicationController
  before_filter :authenticate_user!

  def create
    class_name = params[:class_name]
    if class_name == "Event"
      @event = Event.find(params[:out][:outable_id])
    else
      @event = Instance.find(params[:out][:outable_id])
    end
    current_user.rsvp_out!(@event)
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.js { render template: "rsvps/outs" }
    end
  end

  def destroy
    @out = Out.find(params[:id])
    @event = @out.outable
    @out.destroy
    if @event.class.name == "Event"
      @event.instances.each do |i|
        @instance_outs = i.outs.where(:flake_id => current_user.id)
        @instance_outs.each do |r| 
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