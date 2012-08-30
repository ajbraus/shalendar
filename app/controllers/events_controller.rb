class EventsController < ApplicationController
  before_filter :authenticate_user!

  require 'active_support/core_ext'

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
        if current_user.post_to_fb_wall? && session[:access_token]
          @graph = Koala::Facebook::API.new(session[:access_token])
          @graph.put_wall_post("#{@event.title}", { :link => "http://www.hoos.in/events/#{@event.id}"}, target_id = 'me')
        end

        if @event.visibility == "invite_only"
          format.html { redirect_to @event }
          format.json { render json: @event, status: :created, location: @event }
        else
          format.html { redirect_to home_path, notice: 'Event saved!'}
          format.json { render json: home_path, status: :created, location: @event }
        end
      else
        format.html { redirect_to home_path, notice: 'Event could not be saved.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /events/id
  #GET /events/id.json
  def show
    @view_requests = Relationship.where("relationships.followed_id = :current_user_id AND
                                         relationships.confirmed = false ", current_user_id: current_user.id)
    
    @event = Event.find(params[:id])
    @guests = @event.guests
    
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
    @invited_users = @invited_users - @event.guests

    @access_token = session[:access_token]
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
      unless current_user.rsvpd?(ie) || current_user == ie.user
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

    @maybe_events = []
    #PUT THIS OUTSIDE OF HERE SO CAN BE USED FOR TIPPED AND UNTIPPED???
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :current_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :current_user_id => current_user.id) #316 ms in console for user1, ~50 followed

    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        unless fp.full? || fp.visibility == "invite_only" || current_user.rsvpd?(fp)
          if fp.tipped?
            if fp.user == f || fp.visibility == "friends_of_friends"
              i = Invite.where("invites.event_id = :current_event_id AND invites.email = :current_user_email",
               current_event_id: fp.id, current_user_email: current_user.email)
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
                                   where('relationships.follower_id = :current_user_id AND relationships.toggled = true AND relationships.confirmed = true',
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
      unless current_user.rsvpd?(ie) || current_user == ie.user
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



  # Mobile: replaced current_user by @mobile_user for now, which is User w/ id 3
  # Only give maybes and plans, send tipped separately. Invitations are maybes, but get notification too
  
  def mobile_maybes
    @mobile_user = User.find_by_id(3)
    @invitation_events = Event.joins('INNER JOIN invites ON events.id = invites.event_id')
                                .where('invites.email = :mobile_user_email', mobile_user_email: @mobile_user.email)
    @toggled_invitation_events = []

    @invitation_events.each do |ie|
      if ie.starts_at.to_date == Date.today || ie.ends_at.to_date == Date.today
        unless @mobile_user.rsvpd?(ie) || @mobile_user == ie.user
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

    @maybe_events = []
    #PUT THIS OUTSIDE OF HERE SO CAN BE USED FOR TIPPED AND UNTIPPED???
    @toggled_followed_users = User.joins('INNER JOIN relationships ON users.id = relationships.followed_id')
                                    .where('relationships.follower_id = :mobile_user_id AND 
                                      relationships.toggled = true AND relationships.confirmed = true',
                                      :mobile_user_id => @mobile_user.id) #316 ms in console for user1, ~50 followed


    @toggled_followed_users.each do |f|
      f.plans.each do |fp| #for friends of friends events that are RSVPd for
        unless fp.full? || fp.visibility == "invite_only" || @mobile_user.rsvpd?(fp)
          if fp.user == f || fp.visibility == "friends_of_friends"
            if fp.starts_at.to_date == Date.today
              @maybe_events.push(fp)
            end
          end
        end
      end
    end

    @events = @maybe_events | @toggled_invitation_evenaawts

    #@events = @events.where('events.start_time >= ')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json

  def mobile_plans
    @mobile_user = User.find_by_id(3)
    @events = @mobile_user.plans

    @scoped_plans = []
    @events.each do |e|
      if e.starts_at.to_date == Date.today #won't work for >2 day events
        @scoped_plans.push(e)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scoped_plans }
      # An attempt at a customized json feed... didn't go so well
      #format.json { render @scoped_plans.to_json(:only => [:id, :title, :start_time]) }
    end
  end
end
