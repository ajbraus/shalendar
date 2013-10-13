class Api::V4::InstancesController < ApiController
  respond_to :json
  
  def new
    # [:event_id]
    
    @event = Event.find(params([:event_id])
    respond_with @event.instances.new
  end

  def create
    # [:instance][:starts_at, :ends_at, :duration]
    # [:event_id]

    @event = Event.find(params([:event_id])
    @instance = @event.instances.build(params[:instance])
    @instance.city = @event.city
    @instance.visibility = @event.visibility

    if @instance.save
      current_user.rsvp_in!(@instance)
      respond_with @event
    end
  end

  def edit
    # [:id]
    respond_with Instance.find(params[:id])
  end

  def update
    # [:id]
    @instance = Instance.find(params[:id])
    @instance.update_attributes(params[:instance])
  end

  def destroy
    # [:id]
    @instance = Instance.find(params[:id])
    @instance.destroy
  end
end