class Api::V2::EventsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
   
  def invites
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @invites_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?)', Time.now, true)
                .joins(:invitations).where(invitations: {invited_user_id: @mobile_user.id}).order("RANDOM()")

    @events = @invites_ideas
    @events = @events.reject{|e| @mobile_user.out?(e)}

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @inviter_id = nil
      if @mobile_user.invited?(e)
        @inviter_id = e.invitations.find_by_invited_user_id(@mobile_user.id).inviter_id
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @instances = []
      if e.one_time?
        @instance = {
            :iid => e.id,
            :gcnt => e.guests.count,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e)
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.now && !@mobile_user.out?(i)
          @instance = {
            :iid => i.id,
            :gcnt => i.guests.count,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i)
          }
          @instances.push(@instance)
        end
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.in?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e),
        :instances => @instances,
        :ot => e.one_time
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def city_ideas
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @city_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?) AND is_public = ? AND city_id = ?', Time.now, true, true, @current_city.id)

    @events = @city_ideas
    @events = @events.reject{|e| @mobile_user.out?(e)}

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @instances = []
      if e.one_time?
        @instance = {
            :iid => e.id,
            :gcnt => e.guests.count,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e)
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.now && !@mobile_user.out?(i)
          @instance = {
            :iid => i.id,
            :gcnt => i.guests.count,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i)
          }
          @instances.push(@instance)
        end
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e),
        :ot => e.one_time
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def ins
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @ins_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?)', Time.now, true).joins(:rsvps)
                      .where(rsvps: {guest_id: @mobile_user.id, inout: 1})

    @events = @ins_ideas

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @instances = []
      if e.one_time?
        @instance = {
            :iid => e.id,
            :gcnt => e.guests.count,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e)
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.now && !@mobile_user.out?(i)
          @instance = {
            :iid => i.id,
            :gcnt => i.guests.count,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i)
          }
          @instances.push(@instance)
        end
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e),
        :ot => e.one_time?
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def my_ideas
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
    end

    @my_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?) AND user_id = ?', Time.now, true, @mobile_user.id)

    @events = @my_ideas

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @g_share = true
      if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
        @g_share = false
      end
      @instances = []
      if e.one_time?
        @instance = {
            :iid => e.id,
            :gcnt => e.guests.count,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e)
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.now && !@mobile_user.out?(i)
          @instance = {
            :iid => i.id,
            :gcnt => i.guests.count,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i)
          }
          @instances.push(@instance)
        end
      end
      @temp = {
        :eid => e.id,
        :title => e.title,  
        :start => e.starts_at,#don't do timezone here, do it local on mobile
        :end => e.ends_at, 
        :gcnt => e.guests.count,  
        :tip => e.min,
        :image => e.image(:medium), 
        :host => e.user,
        :plan => @mobile_user.rsvpd?(e),
        :tipped => e.tipped,
        :gids => @guestids,
        :g_share => @g_share,
        :share_a => @mobile_user.invited_all_friends?(e),
        :ot => e.one_time?
      }
      @list_events.push(@temp)
    end 
    render json: @list_events
  end

  def event_details
    #this will give mobile the info about the guests of the event
    #could add invites here, and/or comments
    @event = Event.find_by_id(params[:event_id])
    if @event.has_parent? #make the detail event always the idea
      @event = @event.parent
    end
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    end
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
    else
      @g_share = true
      @invitedids = []
      @event.invited_users.each do |i|
        @invitedids.push(i.id)
      end
      @price = 0
      unless @event.price.nil?
        @price = @event.price
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      @inviter = nil
      if @mobile_user.invited?(@event)
        @inviter = @mobile_user.invitations.where(invited_event_id: @event.id).first.inviter
      end
      e = @event
      @instances = []
      if e.one_time?
        @instance = {
            :iid => e.id,
            :gcnt => e.guests.count,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e)
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.now && !@mobile_user.out?(i)
          @instance = {
            :iid => i.id,
            :gcnt => i.guests.count,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i)
          }
          @instances.push(@instance)
        end
      end
      render json: { 
          :eid => @event.id,
          :title => @event.title,  
          :start => @event.starts_at,
          :end => @event.ends_at, 
          :gcnt => @event.guests.count,
          :tip => @event.min,  
          :host => @event.user,
          :plan => @mobile_user.rsvpd?(@event),
          :tipped => @event.tipped,
          :guests => @event.guests,
          :iids => @invitedids,
          :g_share => @g_share,
          :comments => @comments,
          :image => @event.image(:medium),
          :url => @event.short_url,
          :price => @price,
          :address => @event.address,
          :link => @event.link,
          :inviter => @inviter,
          :share_a => @mobile_user.invited_all_friends?(@event),
          :instances => @instances,
          :ot => @event.one_time
        }
    end
  end

  def mobile_create
    logger.info("CREATEPARAMS #{params}")
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end

    @guests_can_invite_friends = true
    @min = 1
    unless params[:min] == ""
      @min = Float(params[:min])
    end
    @max = 100000
    unless params[:max] == ""
      @max = Float(params[:max])
    end

    @img_url = ""
    if params[:upload_img].present?
      #Do something to upload the image...
      #then put it into @img_url
    elsif params[:img_url].present?
      @img_url = params[:img_url]
    end

    @event_params = {
      title: params[:title],
      #chronic_starts_at: DateTime.parse(params[:start]),
      #duration: Float(params[:duration]),
      guests_can_invite_friends: @guests_can_invite_friends,
      min: @min,
      min: @min,
      max: @max,
      link: params[:link],
      price: params[:price],
      address: params[:address],
      is_public: 0,
      family_friendly: 0,
      promo_url: "",
      promo_vid: "",
      promo_img: params[:promo_img],
      description: params[:description]
    }

    @event = @mobile_user.events.build(@event_params)
    # @event.user = @mobile_user
    # @event.chronic_starts_at = DateTime.parse(params[:start])
    if params[:start].present? && params[:duration].present?
      @event.starts_at = DateTime.parse(params[:start])
      @event.duration = Float(params[:duration])
      @event.ends_at = @event.starts_at + @event.duration*3600
    end
    if params[:invite_city] == '1'
      @event.is_public = true
    end
    if @current_city.present?
      @event.city = @current_city
    elsif @mobile_user.city.present?
      @event.city = @mobile_user.city
    else
      @event.city = City.find_by_name("Madison, Wisconsin")
    end

    @event.tipped = true if @event.min <= 1
 
    #Make Instance
    if params[:add_time] == '1' && @event.starts_at.present? && @event.duration.present?
      #SET ENDS_AT IF PRESENT
      @event.ends_at = @event.starts_at + @event.duration*3600
      if params[:one_time] == '0' #IF NOT one time, CREATE instance
        
        @instance = @event.instances.build(user_id: current_user.id,
                                 city_id: @event.city.id,
                                 title: @event.title,
                                 starts_at: @event.starts_at,
                                 ends_at: @event.ends_at,
                                 duration: @event.duration,
                                 min: @event.min,
                                 max: @event.max,
                                 address: @event.address,
                                 link: @event.link,
                                 guests_can_invite_friends: @event.guests_can_invite_friends,
                                 promo_img: @event.promo_img,
                                 promo_url: @event.promo_url,
                                 promo_vid: @event.promo_vid,
                                 is_public: @event.is_public,
                                 family_friendly: @event.family_friendly,
                                 price: @event.price,
                                 description: @event.description
                              )
        if @instance.save
          @instance.save_shortened_url
          current_user.rsvp_in!(@instance)
          if params[:invite_all] == "1"
            current_user.invite_all_friends!(@instance)
          end
          @instance.tipped = true   if @instance.min <= 1
          
          #CLEAR PARENT EVENT TIME ATTRIBUTES
          @event.starts_at = nil
          @event.ends_at = nil
          @event.duration = nil
        end # END if instance.save
      else #it's a one-time
        @event.one_time = true
      end #END if ongoing event create instance
    end #END if starts_at present
    if @event.save
      @mobile_user.rsvp_in!(@event)
      @event.save_shortened_url
      if params[:invite_all] == '1'
        @mobile_user.invite_all_friends!(@event)
      end
      if params[:category_id]
        Categorization.create(event_id: @event.id, category_id: params[:category_id])
      end
      if @instance.present?
        if @event.categorizations.any?
          Categorization.create(event_id: @instance.id, category_id: @event.categorizations.first.id )
        end
      end
      @g_share = true
      @invitedids = []
      @event.invited_users.each do |i|
        @invitedids.push(i.id)
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      render json: { 
          :eid => @event.id,
          :title => @event.title,  
          :start => @event.starts_at,
          :end => @event.ends_at, 
          :gcnt => @event.guests.count,
          :tip => @event.min,  
          :host => @event.user,
          :plan => @mobile_user.rsvpd?(@event),
          :tipped => @event.tipped,
          :guests => @event.guests,
          :iids => @invitedids,
          :g_share => @g_share,
          :comments => @comments,
          :image => @event.image(:medium),
          :url => @event.short_url,
          :share_a => @mobile_user.invited_all_friends?(@event),
          :description => @event.description
        }
    else
      render :status => 400, :json => {:error => "Idea did not Save"}
    end
  end

  def add_comment
    #could add invites here, and/or comments
    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
    elsif @event.nil?
      render :status => 400, :json => {:error => "could not find your event"}
    else
      @message = params[:comment]
      @comment = @event.comments.new
      @comment.user = @mobile_user
      @comment.content = @message
      if @comment.save
        render :status => 200, :json => {:success => true, comment: {msg: @comment.content, name: @comment.user.name, date: @comment.created_at}}
      else
        render :status => 400, :json => {:error => "could not save comment"}
      end
    end
  end

  def cancel_idea

    @event = Event.find_by_id(params[:event_id])
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{:error => "event was not found."}
    end
    if @mobile_user != @event.user
      render :status=>300, :json=>{:error => "you don't have the authority to cancel this event"}
    end
    @event.contact_cancellation
        render :json=> { :success => true
        }, :status=>200
  end

  def add_photo
    @mobile_user = User.find_by_id(params[:user_id])
    @event = Event.find_by_id(params[:event_id])
    if @mobile_user.nil? || @event.nil?
      render :status => 400, :json => {:error => "couldn't find event or user"}
    end
    if @mobile_user.id != @event.user.id
      render :status => 400, :json => {:error => "thinks that your user is not the host of the event"}
    end

    @userfile = params[:userfile]

    logger.info(params)

    render :status => 200, :json => {:success => "got here at least"}
  end


end