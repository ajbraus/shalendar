class Api::V1::EventsController < ApplicationController
   before_filter :authenticate_user!
   
   def user_events_on_date
    #receive call to : calenshare.com/user_plans_on_date.json?date="DateInString"
    raw_datetime = DateTime.parse(params[:date])
    @mobile_user = User.find_by_id(3)
    #@events = current_user.plans_on_date(raw_date)
    @events = @mobile_user.mobile_events_on_date(raw_datetime)

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
        @temp = {
        :id => e.id,
        :title => e.title,  
        :start => e.starts_at,  
        :guest_count => e.guests.count,  
        :min_to_tip => e.min,  
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e)
        }
     	@list_events.push(@temp)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @list_events }
    end
  end

  def event_details
    #this will give mobile the info about the guests of the event
    #could add invites here, and/or comments
    @event = Event.find_by_id(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event }
    end
  end


end