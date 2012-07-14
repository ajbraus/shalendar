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

    #this will eventually populate with all followed + wanted to be displayed events
    #basically, loop through following (and toggled), add any of their created events
    
    @followed_events = []

    @followed_users = current_user.followed_users

    @followed_users.each { |f|
      f.events.each{ |fe|     #FOR only friend events
        @followed_events.push(fe)
      }
      # f.plans.each{ |fp| #for friends of friends events that are RSVPd for
      #   @followed_events.push(fp)
      # }
    }

    @maybe_events = [] #an empty array to fill with relevant events

    #take main list and remove already RSVP'd events
    @followed_events.each { |e|
      plan = false
      unless(e.full?)
        if(e.tipped?)
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
        end  
      end
    }
    
    #The best ideas for SQL query implementation...
    #Find events where [user.id, event.id] doesn't exist in RSVP table
    #@events = Event.all
    #@events = @events.where("[ ? , ? ] NOT IN rsvps", 5, 2)
    #@events = @events.joins('rsvps').on('plan_id').where("rsvps.guest_id != ?", current_user.id)
    #@events = Event.scope
    
    #PROBLEM HERE, EVENTS will not load with these on under current hack
    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maybe_events }
    end
  end

  # GET /events/1
  # GET /events/1.json

  def my_plans
  
    @events = current_user.plans

    @plans = []

    @events.each { |e|
      if(e.tipped?)
        unless(e.user == current_user)
          @plans.push(e)
        end
      end
    }

    @events = @plans

    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def my_events
  
    @events = current_user.events

    @my_events = []

    @events.each { |e|
      if(e.tipped?)
        @my_events.push(e)
      end
    }

    @events = @my_events
    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end



  def my_untipped_maybes

    @followed_events = []

    @followed_users = current_user.followed_users

    @followed_users.each { |f|
      # f.events.each{ |fe|     #FOR only friend events
      #   @followed_events.push(fe)
      # }
      f.plans.each{ |fp| #for friends of friends events that are RSVPd for
        @followed_events.push(fp)
      }
    }

    @maybe_events = [] #an empty array to fill with relevant events

    #take main list and remove already RSVP'd events
    @followed_events.each { |e|
      plan = false
      unless(e.full?)
        unless(e.tipped?)
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
        end  
      end
    }

    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maybe_events }
    end
  end

  def my_untipped_plans
  
    @events = current_user.plans

    @plans = []

    @events.each { |e|
      unless(e.tipped?)
        unless(e.user == current_user)
          @plans.push(e)
        end
      end
    }

    @events = @plans

    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end


  def my_untipped_events
  
    @events = current_user.events
    @my_events = []

    @events.each { |e|
      unless(e.tipped?)
        @my_events.push(e)
      end 
    }

    @events = @my_events

    #@events = @events.after(params['start']) if (params['start'])
    #@events = @events.before(params['end']) if (params['end'])

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
        format.html { redirect_to root_path }
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
