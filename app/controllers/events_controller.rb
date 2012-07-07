class EventsController < ApplicationController
  before_filter :authenticate_user!
  # GET /events
  # GET /events.json
  def index

    @events = Event.scoped
    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def my_maybes

    @events = Event.all
    
    @maybe_events = [] #this will eventually populate with all followed + wanted to be displayed events

    #take that list and don't re-display already RSVP'd events
    @events.each { |e|
      plan = false
      e.guests.each{ |g|
        if g == current_user
          plan = true
        end
      }
      if e.user == current_user
        plan = true
      end
      if plan == false
        @maybe_events.push(e)
      end
    }
    @events = @maybe_events
    
    #@events = @events.joins('rsvps').on('plan_id').where("rsvps.guest_id != ?", current_user.id)
    #@events = Event.scope
    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json

  def my_plans
  
    @events = current_user.plans.scoped
    @events = @events.where("user_id != ?", current_user.id)
    #@events = @events.not_my_events

    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def my_events
  
    @events = current_user.events.scoped
    #@events = Event.where("user_id = ?", current_user.id).scoped
    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def show
    @event = Event.find(params[:id])
    @guests = @event.guests

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    #@user = current_user - old
    @event = current_user.events.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(params[:event])

    respond_to do |format|
      if @event.save
        current_user.rsvp!(@event)
        format.html { redirect_to root_path, notice: 'Event was successfully created.' }
        format.json { render json: root_path, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end
end
