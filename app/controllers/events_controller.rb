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

  # GET /events/new
  # GET /events/new.json
  def new
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

        # if @event.invite?
        #   Notifier.send_invites(@event)
        # end

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
    @event = Event.find(params[:id])
    @guests = @event.guests
    @starttime = @event.starts_at.strftime "%l:%M%P, %A %B %e"
    @endtime = @event.ends_at.strftime "%l:%M%P, %A %B %e"
    @invites = @event.invites
    @access_token = session[:fb_access_token]
    @graph = Koala::Facebook::API.new(@access_token)
    @comments = @event.comments.order "created_at desc"
#    @comment_created_at = @comment.created_at.strftime "%l:%M%P, %A %B %e"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @start_time = @event.starts_at
    @location = @event.location
    respond_to do |format|
      if @event.update_attributes(params[:event])

        if @start_time != @event.starts_at
          Notifier.time_change(@event).deliver
        elsif @location != @event.location
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
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :current_user_email', current_user_email: current_user.email)
    @toggled_invitation_events = []

     @invitation_events.each do |ie|
      unless current_user.rsvpd?(ie)
        if ie.tipped?
          if current_user.following?(ie.user)
            if current_user.relationships.find_by_followed_id(ie.user).toggled?
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
    @followed_events = []
    #PUT THIS OUTSIDE OF HERE SO CAN BE USED FOR TIPPED AND UNTIPPED???
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :current_user_id AND 
                                      relationships.toggled = "t" AND relationships.confirmed = "t"',
                                      :current_user_id => current_user.id) #316 ms in console for user1, ~50 followed

    @toggled_followed_users.each { |f|
      f.plans.each{ |fp| #for friends of friends events that are RSVPd for
        if fp.user == f
          @followed_events.push(fp)
        elsif fp.visibility == "friends_of_friends"
          @followed_events.push(fp)
          # For actualy 2deg separation
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
              i = Invite.where("invites.event_id = :current_event_id AND invites.email = :current_user_email",
                               current_event_id: e.id, current_user_email: current_user.email)
              if i.empty?
                @maybe_events.push(e)
              end
            end
          end  
        end
      end
    }
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
    #@followed_users = current_user.followed_users
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id').
                                   where('relationships.follower_id = :current_user_id AND relationships.toggled = "t" AND relationships.confirmed = "t"',
                                   :current_user_id => current_user.id)
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
              if g == current_user
               plan = true
              end
            }
            if e.user == current_user
              plan = true
            end
            if plan == false
              i = Invite.where("invites.event_id = :current_event_id AND invites.email = :current_user_email",
                                current_event_id: e.id, current_user_email: current_user.email)
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

  def my_untipped_invitations
    @invitation_events = Event.joins('INNER JOIN invites on events.id = invites.event_id')
                               .where('invites.email = :current_user_email', current_user_email: current_user.email)

    @toggled_invitation_events = []

    @invitation_events.each do |ie|
      unless current_user.rsvpd?(ie)
        unless ie.tipped?
          if current_user.following?(ie.user)
            if current_user.relationships.find_by_followed_id(ie.user).toggled?
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
