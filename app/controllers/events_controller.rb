class EventsController < ApplicationController
  # before_filter :authenticate_user!


  ## FOR MOBILE- CHANGED ALL current_user to @mobile_user (which is User.find_by_id(3))
  # GET /events
  # GET /events.json
  def index
    @mobile_user = User.find_by_id(3)
    @events = Event.scoped
    @events = @events.after(params['start']) if (params['start'])
    @events = @events.before(params['end']) if (params['end'])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @mobile_user = User.find_by_id(3)
    @event = @mobile_user.events.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @mobile_user = User.find_by_id(3)
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @mobile_user = User.find_by_id(3)
    @event = @mobile_user.events.build(params[:event])
    respond_to do |format|
      if @event.save
        @mobile_user.rsvp!(@event)

        if @event.visibility == "invite_only"
          format.html { redirect_to @event }
          format.json { render json: @event, status: :created, location: @event }
        else
          format.html { redirect_to home_path }
          format.json { render json: home_path, status: :created, location: @event }
        end
      else
        format.html { render action: "new", notice: 'Comment could not be saved.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @mobile_user = User.find_by_id(3)
    @event = Event.find(params[:id])
    @guests = @event.guests
    @starttime = @event.starts_at.strftime "%l:%M%P, %A %B %e"
    @endtime = @event.ends_at.strftime "%l:%M%P, %A %B %e"

    #separating invites by email from invites who are users
    @invites = []
    @invited_users = []
    @event.invites.each do |i|
      if u = User.find_by_email(i.email)
        @invited_users.push(u)
      else
        @invites.push(i)
      end
    end
    unless @event.visibility == "invite_only" 
      @invited_users = @invited_users | @event.user.followers
    end
    @invited_users = @invited_users - @event.guests

    @access_token = session[:fb_access_token]
    @graph = Koala::Facebook::API.new(@access_token)
    @comments = @event.comments.order "created_at desc"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @mobile_user = User.find_by_id(3)
    @event = Event.find(params[:id])
    @start_time = @event.starts_at
    @location = @event.map_location
    respond_to do |format|
      if @event.update_attributes(params[:event])

        if @start_time != @event.starts_at
          Notifier.time_change(@event).deliver
        elsif @location != @event.map_location
          Notifier.location_change(@event).deliver
        else
          Notifier.noncritical_change(@event).deliver
        end

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
    @mobile_user = User.find_by_id(3)
    @event = Event.find(params[:id])

    Notifier.cancellation(@event).deliver

    @event.destroy


    respond_to do |format|
      format.html { redirect_to home_path }
      format.json { head :no_content }
    end
  end


  # TO PRUNE DATABASE
  # def clean_up
  #   @event = Event.find(params[:id])

  #   @event.destroy

  #   respond_to do |format|
  #     format.html { redirect_to home_path }
  #     format.json { head :no_content }
  #   end
  # end

  def my_invitations
    @mobile_user = User.find_by_id(3)
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :@mobile_user_email', @mobile_user_email: @mobile_user.email)
    @toggled_invitation_events = []

     @invitation_events.each do |ie|
      unless @mobile_user.rsvpd?(ie) || @mobile_user == ie.user
        if ie.tipped?
          if @mobile_user.following?(ie.user)
            if @mobile_user.relationships.find_by_followed_id(ie.user).toggled?
              @toggled_invitation_events.push(ie)
            end
          else
            @toggled_invitation_events.push(ie)
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @toggled_invitation_events }
    end
  end

  def my_maybes
    @mobile_user = User.find_by_id(3)
    @maybe_events = []
    #PUT THIS OUTSIDE OF HERE SO CAN BE USED FOR TIPPED AND UNTIPPED???
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :@mobile_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :@mobile_user_id => @mobile_user.id) #316 ms in console for user1, ~50 followed

    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        unless fp.full? || fp.visibility == "invite_only" || @mobile_user.rsvpd?(fp)
          if fp.tipped?
            if fp.user == f || fp.visibility == "friends_of_friends"
              i = Invite.where("invites.event_id = :current_event_id AND invites.email = :@mobile_user_email",
               current_event_id: fp.id, @mobile_user_email: @mobile_user.email)
              if i.empty?
                @maybe_events.push(fp)
              end
            end
          end
        end
      end
    end

    #PROBLEM HERE, EVENTS will not load with these on
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
    @mobile_user = User.find_by_id(3)
    @events = @mobile_user.plans
    @plans = []

    @events.each { |e|
      if(e.tipped?)
        unless(e.user == @mobile_user)
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
    @mobile_user = User.find_by_id(3)
    @events = @mobile_user.events
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
    @mobile_user = User.find_by_id(3)
    @followed_events = []
    #@followed_users = @mobile_user.followed_users
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id').
                                   where('relationships.follower_id = :@mobile_user_id AND relationships.toggled = true AND relationships.confirmed = true',
                                   :@mobile_user_id => @mobile_user.id)
    @toggled_followed_users.each { |f|
      f.plans.each{ |fp| #for friends of friends events that are RSVPd for
        if fp.user == f
          @followed_events.push(fp)
        elsif fp.visibility == "friends_of_friends"
          @followed_events.push(fp)
          # For actual 2 degree separation only:
          # if f.following?(fp.user)
          #   @followed_events.push(fp)
          # end
        end
      }
    }
    @maybe_events = [] #an empty array to fill with relevant events

    #take main list and remove already RSVP'd events
    @followed_events.each { |e|
      plan = false
      unless(e.full?)
        unless(e.visibility == "invite_only")
          unless(e.tipped?)
            e.guests.each{ |g|
              if g == @mobile_user
               plan = true
              end
            }
            if e.user == @mobile_user
              plan = true
            end
            if plan == false
              i = Invite.where("invites.event_id = :current_event_id AND invites.email = :@mobile_user_email",
                                current_event_id: e.id, @mobile_user_email: @mobile_user.email)
              if i.empty?
                @maybe_events.push(e)
              end
            end
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
    @mobile_user = User.find_by_id(3)
    @events = @mobile_user.plans
    @plans = []
    @events.each { |e|
      unless(e.tipped?)
        unless(e.user == @mobile_user)
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
    @mobile_user = User.find_by_id(3)
    @events = @mobile_user.events
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

  def my_untipped_invitations
    @mobile_user = User.find_by_id(3)
    @invitation_events = Event.joins('INNER JOIN invites on events.id = invites.event_id')
                               .where('invites.email = :@mobile_user_email', @mobile_user_email: @mobile_user.email)

    @toggled_invitation_events = []

    @invitation_events.each do |ie|
      unless @mobile_user.rsvpd?(ie) || @mobile_user == ie.user
        unless ie.tipped?
          if @mobile_user.following?(ie.user)
            if @mobile_user.relationships.find_by_followed_id(ie.user).toggled?
              @toggled_invitation_events.push(ie)
            end
          else
            @toggled_invitation_events.push(ie)
          end
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @toggled_invitation_events }
    end

  end
end
