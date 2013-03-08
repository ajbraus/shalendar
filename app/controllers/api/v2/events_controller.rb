class Api::V2::EventsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json
   
  def invites
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    unless params[:count].nil?
      @count = Integer(params[:count])
    end
    @finished = false
    @window_size = 7

    @invites_ideas = Event.where('city_id = ? AND ends_at IS NULL', @current_city.id).reject { |i| current_user.out?(i) || current_user.in?(i) || i.no_relevant_instances? }

    @invites_ideas = @invites_ideas.reject do |i| 
      !current_user.in?(i) && (current_user.out?(i) || (current_user.inmates & i.guests).none? || (i.friends_only && !current_user.in?(i) && !i.user.is_friends_with?(current_user)))
    end
    #ADAM's ATTEMPT AT THIS QUERY WITH NO SINGLETON ONE_TIMES AND WITH EAGER LOADING GUESTS AND INSTANCES
    # @invites_ideas = Event.includes(:instances, {:rsvps => :guest}).where('city_id = ? AND ends_at IS NULL', @current_city.id).reject { |e| e.no_relevant_instances? }

    # @invites_ideas = @invites_ideas.reject do |i| 
    #   !current_user.in?(i) && (current_user.out?(i) || !current_user.invited?(i))
    # end

    @invites_ideas = @invites_ideas.sort_by do |i| 
        i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count*1000 + 
            i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 1, current_user.id).count
    end
    @events = @invites_ideas

    if (@count + @window_size) < @events.count
      @events = @events[@count .. @count + @window_size-1]
    elsif @count >= @events.count #we'd overstep the array bounds
      @finished = true
    else #we are done once this is done
      @events = @events[@count .. (@events.count-1)]
      @finished = true
    end

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @instances = []
      if e.one_time?
        if e.instances.any?
          e = e.instances.first
        end
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      else
        e.instances.each do |i|
          if i.ends_at > Time.zone.now
            @i_guestids = []
            i.guests.each do |g|
              @i_guestids.push(g.id)
            end
            @instance = {
              :iid => i.id,
              :gids => @i_guestids,
              :start => i.starts_at,
              :end => i.ends_at,
              :address => i.address,
              :plan => @mobile_user.in?(i),
              :out => @mobile_user.out?(i),
              :host => i.user
            }
            @instances.push(@instance)
          end
        end
      end
      @temp = {
        :eid => e.id,
        :host => e.user,
        :title => e.title,  
        :image => e.image(:medium),
        :plan => @mobile_user.in?(e),
        :gids => @guestids,
        :instances => @instances,
        :ot => e.one_time
      }
      @list_events.push(@temp)
    end 
    render json: {
          :finished => @finished,
          :events => @list_events
    }
  end

  def ins
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    unless params[:count].nil?
      @count = Integer(params[:count])
    end
    @finished = false
    @window_size = 7

    @ins_ideas = @mobile_user.plans.where('ends_at IS NULL', Time.zone.now, true).reject{ |i| i.no_relevant_instances?}
    #ADAM's ATTEMPT AT THIS QUERY WITH NO SINGLETON ONE_TIME IDEAS AND EAGER LOADING OF INSTANCES AND GUESTS
    # @ins_ideas = @mobile_user.plans.includes(:instances, {:rsvps => :guest}).where('city_id = ? AND ends_at IS NULL', @current_city.id).reject { |e| e.no_relevant_instances? }

    @ins_ideas = @ins_ideas.sort_by do |i| 
        i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count*1000 + 
            i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 1, current_user.id).count
    end
    @events = @ins_ideas

    if (@count + @window_size) < @events.count
      @events = @events[@count .. @count + @window_size-1]
    elsif @count >= @events.count #we'd overstep the array bounds
      @finished = true
    else #we are done once this is done
      @events = @events[@count .. (@events.count-1)]
      @finished = true
    end

    #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @instances = []
      if e.one_time?
        if e.instances.any?
          e = e.instances.first
        end
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      else
        e.instances.each do |i|
          if i.ends_at > Time.zone.now
            @i_guestids = []
            i.guests.each do |g|
              @i_guestids.push(g.id)
            end
            @instance = {
              :iid => i.id,
              :gids => @i_guestids,
              :start => i.starts_at,
              :end => i.ends_at,
              :address => i.address,
              :plan => @mobile_user.in?(i),
              :out => @mobile_user.out?(i),
              :host => i.user
            }
            @instances.push(@instance)
          end
        end
      end
      @temp = {
        :eid => e.id,
        :host => e.user,
        :title => e.title,  
        :image => e.image(:medium),
        :plan => @mobile_user.in?(e),
        :gids => @guestids,
        :instances => @instances,
        :ot => e.one_time
      }
      @list_events.push(@temp)
    end 
    render json: {
      :finished => @finished,
      :events => @list_events
    }
  end

  def prune_ins
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    @x = params[:event_ids]
    @event_ids = @x[1..-2].split(',').collect! {|n| n.to_i}
    @ins_ideas = @mobile_user.plans.where('ends_at IS NULL OR ends_at > ?', Time.zone.now)
    @relevant_ids = []
    @irrelevant_ids = []
    @ins_ideas.each do |ii|
      @relevant_ids.push(ii.id)
    end
    @event_ids.each do |eid|
      @relevant = false
      e = Event.find(eid)
      if e.present?
        if e.ends_at.present?
          if e.ends_at > Time.zone.now
            @relevant = true
          end
        else
          @relevant_ids.each do |rid|
            if eid == rid
              @relevant = true
            end
          end
        end
      end
      if !@relevant
        @irrelevant_ids.push(eid)
      end
    end
    render json: {
      :irrelevant_ids => @irrelevant_ids
    }
  end

  def prune_invites
    @mobile_user = User.find_by_id(params[:user_id])

    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    else
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    @invites = Event.where('city_id = ? AND (ends_at IS NULL OR ends_at > ?)', @current_city.id, Time.now).reject { |i| current_user.out?(i) || current_user.in?(i)}
    @invites = @invites.reject do |i|
      if i.has_parent?
        i.friends_only && !current_user.in?(i) && !current_user.in?(i.parent) && !i.user.is_friends_with?(current_user)
      else
        i.friends_only && !current_user.in?(i) && !i.user.is_friends_with?(current_user)
      end
    end
    @relevant_ids = []
    @irrelevant_ids = []
    @invites.each do |ii|
      @relevant_ids.push(ii.id)
    end
    @x = params[:event_ids]
    @event_ids = @x[1..-2].split(',').collect! {|n| n.to_i}
    @event_ids.each do |eid|
      @relevant = false
      e = Event.find(eid)
      if e.present?
        if e.ends_at.present?
          if e.ends_at > Time.now
            @relevant = true
          end
        else
          @relevant_ids.each do |rid|
            if eid == rid
              @relevant = true
            end
          end
        end
      end
      if !@relevant
        @irrelevant_ids.push(eid)
      end
    end
    render json: {
      :irrelevant_ids => @irrelevant_ids
    }
  end

  def event_details
    @event = Event.find_by_id(params[:event_id])
    if @event.nil?
      render :status => 400, :json => {:error => "could not find event"}
      return
    end

    if @event.has_parent? #make the detail event always the idea- and get times
      @event = @event.parent
    end
    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.present?
      Time.zone = @mobile_user.city.timezone
    end
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    else
      @price = 0
      unless @event.price.nil?
        @price = @event.price
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      @comments = @comments.reverse
      e = @event
      @instances = []
      if e.one_time?
        if e.instances.any?
          e = e.instances.first
        end
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.zone.now
          @i_guestids = []
          i.guests.each do |g|
            @i_guestids.push(g.id)
          end
          @instance = {
            :iid => i.id,
            :gids => @i_guestids,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i),
            :out => @mobile_user.out?(i),
            :host => i.user
          }
          @instances.push(@instance)
        end
      end
      render json: { 
        :eid => @event.id,
        :title => @event.title,  
        :start => @event.starts_at,
        :description => @event.description,
        :end => @event.ends_at, 
        :gcnt => @event.guests.count,
        :host => @event.user,
        :plan => @mobile_user.rsvpd?(@event),
        :guests => @event.guests,
        :comments => @comments,
        :image => @event.image(:medium),
        :url => @event.short_url,
        :price => @price,
        :address => @event.address,
        :link => @event.link,
        :instances => @instances,
        :ot => @event.one_time        
      }
    end
  end

  def mobile_create

    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    @img_url = ""
    if params[:upload_img].present?
      #Do something to upload the image...
      #then put it into @img_url
    elsif params[:img_url].present?
      @img_url = params[:img_url]
    end
    @starts_at = nil
    @ends_at = nil
    @duration = nil
    

    if params[:start].present? && params[:duration].present?
      @starts_at = DateTime.parse(params[:start])
      @duration = Float(params[:duration])
      @ends_at = @starts_at + @duration.hours
    end
    @one_time = false
    if params[:one_time].present?
      @one_time = params[:one_time]
    end
    @address = nil
    if params[:address].present?
      @address = params[:address]
    end
    @price = nil
    if params[:price].present?
      @price = params[:price]
    end
    @link = nil
    if params[:link].present?
      @link = params[:link]
    end
    @description = nil
    if params[:description].present?
      @description = params[:description]
    end
    @friends_only = false
    if params[:friends_only].present?
      @friends_only = params[:friends_only]
    end

    @event_params = {
      title: params[:title],
      starts_at: @starts_at,
      ends_at: @ends_at,
      duration: @duration,
      one_time: @one_time,
      link: @link,
      price: @price,
      address: @address,
      promo_url: @img_url,
      promo_vid: "",
      promo_img: nil,
      description: @description,
      friends_only: @friends_only,
      family_friendly: false
    }

    @event = @mobile_user.events.build(@event_params)

    if @current_city.present?
      @event.city = @current_city
    elsif @mobile_user.city.present?
      @event.city = @mobile_user.city
    else
      @event.city = City.find_by_name("Madison, Wisconsin")
    end 

    #Make Instance
    if params[:add_time] == '1' && @event.starts_at.present? && @event.duration.present?

      if params[:one_time] == '0' #IF NOT one time, CREATE instance
        #ADAM - COMMENT THIS LINE ABOVE OUT
        
        @instance = @event.instances.build(user_id: current_user.id,
                                 city_id: @event.city.id,
                                 title: @event.title,
                                 starts_at: @event.starts_at,
                                 ends_at: @event.ends_at,
                                 duration: @event.duration,
                                 address: @event.address,
                                 link: @event.link,
                                 promo_img: @event.promo_img,
                                 promo_url: @event.promo_url,
                                 promo_vid: @event.promo_vid,
                                 family_friendly: @event.family_friendly,
                                 price: @event.price,
                                 description: @event.description,
                                 friends_only: @event.friends_only,
                                 one_time: false
                              )
        if @instance.save
          @instance.save_shortened_url
          current_user.rsvp_in!(@instance)

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

      @price = 0
      unless @event.price.nil?
        @price = @event.price
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      @comments = @comments.reverse
      e = @event
      @instances = []
      if e.one_time?
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.zone.now
          @i_guestids = []
          i.guests.each do |g|
            @i_guestids.push(g.id)
          end
          @instance = {
            :iid => i.id,
            :gids => @i_guestids,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i),
            :out => @mobile_user.out?(i),
            :host => i.user
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
        :host => @event.user,
        :plan => @mobile_user.rsvpd?(@event),
        :guests => @event.guests,
        :comments => @comments,
        :image => @event.image(:medium),
        :url => @event.short_url,
        :price => @price,
        :address => @event.address,
        :link => @event.link,
        :instances => @instances,
        :ot => @event.one_time        
      }
    else
      render :status => 400, :json => {:error => "Idea did not Save"}
    end
  end

  def add_time

    @mobile_user = User.find_by_id(params[:user_id])
    if @mobile_user.nil?
      render :status => 400, :json => {:error => "could not find your user"}
      return
    end
    @parent = Event.find_by_id(params[:event_id])
    if @parent.nil?
      render :status => 400, :json => {:error => "could not find your idea"}
      return
    end

    @starts_at = nil
    @ends_at = nil
    @duration = nil
    

    if params[:start].present? && params[:duration].present?
      @starts_at = DateTime.parse(params[:start])
      @duration = Float(params[:duration])
      @ends_at = @starts_at + @duration.hours
    end

    @event = @parent.instances.build(user_id: @mobile_user.id,
                           title: @parent.title,
                           starts_at: @starts_at,
                           ends_at: @ends_at,
                           address: params[:address],
                           duration: @duration,
                           link: @parent.link,
                           promo_img: @parent.promo_img,
                           promo_url: @parent.promo_url,
                           promo_vid: @parent.promo_vid,
                           family_friendly: @parent.family_friendly,
                           price: @parent.price,
                           city_id: @parent.city.id, 
                           friends_only: @parent.friends_only
                           )
    if @event.save
      @event.save_shortened_url
      current_user.rsvp_in!(@event)
      if @parent.guests.any? 
        @parent.guests.each do |g|
          unless g == @mobile_user
            g.delay.contact_new_time(@event)
          end
        end
      end
      @event = @parent
      @price = 0
      unless @event.price.nil?
        @price = @event.price
      end
      @comments = []
      @event.comments.each do |c|
        @c = {msg: c.content, name: c.user.name, date: c.created_at}
        @comments.push(@c)
      end
      @comments = @comments.reverse
      e = @event
      @instances = []
      if e.one_time?
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.zone.now
          @i_guestids = []
          i.guests.each do |g|
            @i_guestids.push(g.id)
          end
          @instance = {
            :iid => i.id,
            :gids => @i_guestids,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i),
            :out => @mobile_user.out?(i),
            :host => i.user
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
        :host => @event.user,
        :plan => @mobile_user.rsvpd?(@event),
        :guests => @event.guests,
        :comments => @comments,
        :image => @event.image(:medium),
        :url => @event.short_url,
        :price => @price,
        :address => @event.address,
        :link => @event.link,
        :instances => @instances,
        :ot => @event.one_time        
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
      return
    elsif @event.nil?
      render :status => 400, :json => {:error => "could not find your event"}
      return
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
      return
    end
    if @event.nil?
      render :status=>400, :json=>{:error => "event was not found."}
      return
    end
    if @mobile_user != @event.user
      render :status=>300, :json=>{:error => "you don't have the authority to cancel this event"}
    end
    @event.guests.each do |g|
      g.delay.contact_cancellation(@event)
    end
    @event.dead = true
    @event.save

    render :json=> { :success => true
    }, :status=>200
  end

  def add_photo
    @mobile_user = User.find_by_id(params[:user_id])
    @event = Event.find_by_id(params[:event_id])
    if @mobile_user.nil? || @event.nil?
      render :status => 400, :json => {:error => "couldn't find event or user"}
      return
    end
    if @mobile_user.id != @event.user.id
      render :status => 400, :json => {:error => "thinks that your user is not the host of the event"}
      return
    end
    @userfile = params[:userfile]
    logger.info("ADD PHOTO PARAMS: #{params}")
    @userfile.content_type = "image/jpeg"
    @event.promo_img = @userfile
    @event.save

    render :status => 200, :json => {:success => "got image uploaded"}
  end


  # def my_ideas
  #   @mobile_user = User.find_by_id(params[:user_id])

  #   if @mobile_user.present?
  #     Time.zone = @mobile_user.city.timezone
  #   else
  #     render :status => 400, :json => {:error => "could not find your user"}
  #   end

  #   @my_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?) AND user_id = ?', Time.zone.now, true, @mobile_user.id)

  #   @events = @my_ideas

  #   #For Light-weight events sending for list (but need guests to know if RSVPd)
  #   @list_events = []
  #   @events.each do |e|
  #     @guestids = []
  #     e.guests.each do |g|
  #       @guestids.push(g.id)
  #     end
  #     @g_share = true
  #     if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
  #       @g_share = false
  #     end
  #     @instances = []
  #     if e.one_time?
  #       @instance = {
  #           :iid => e.id,
  #           :gcnt => e.guests.count,
  #           :start => e.starts_at,
  #           :end => e.ends_at,
  #           :address => e.address,
  #           :plan => @mobile_user.in?(e)
  #       }
  #       @instances.push(@instance)
  #     end
  #     e.instances.each do |i|
  #       if i.ends_at > Time.zone.now && !@mobile_user.out?(i)
  #         @instance = {
  #           :iid => i.id,
  #           :gcnt => i.guests.count,
  #           :start => i.starts_at,
  #           :end => i.ends_at,
  #           :address => i.address,
  #           :plan => @mobile_user.in?(i)
  #         }
  #         @instances.push(@instance)
  #       end
  #     end
  #     @temp = {
  #       :eid => e.id,
  #       :title => e.title,  
  #       :start => e.starts_at,#don't do timezone here, do it local on mobile
  #       :end => e.ends_at, 
  #       :gcnt => e.guests.count,  
  #       :tip => e.min,
  #       :image => e.image(:medium), 
  #       :host => e.user,
  #       :plan => @mobile_user.rsvpd?(e),
  #       :tipped => e.tipped,
  #       :gids => @guestids,
  #       :g_share => @g_share,
  #       :share_a => @mobile_user.invited_all_friends?(e),
  #       :ot => e.one_time,
  #       :pub => e.is_public
  #     }
  #     @list_events.push(@temp)
  #   end 
  #   render json: @list_events
  # end


  # def city_ideas
  #   @mobile_user = User.find_by_id(params[:user_id])

  #   if @mobile_user.present?
  #     Time.zone = @mobile_user.city.timezone
  #   else
  #     render :status => 400, :json => {:error => "could not find your user"}
  #   end

  #   @city_ideas = Event.where('ends_at IS NULL OR (ends_at > ? AND one_time = ?) AND is_public = ? AND city_id = ?', Time.zone.now, true, true, @current_city.id)

  #   @events = @city_ideas
  #   @events = @events.reject{|e| @mobile_user.out?(e)}

  #   #For Light-weight events sending for list (but need guests to know if RSVPd)
  #   @list_events = []
  #   @events.each do |e|
  #     @guestids = []
  #     e.guests.each do |g|
  #       @guestids.push(g.id)
  #     end
  #     @g_share = true
  #     if e.guests_can_invite_friends.nil? || e.guests_can_invite_friends == false
  #       @g_share = false
  #     end
  #     @instances = []
  #     if e.one_time?
  #       @instance = {
  #           :iid => e.id,
  #           :gcnt => e.guests.count,
  #           :start => e.starts_at,
  #           :end => e.ends_at,
  #           :address => e.address,
  #           :plan => @mobile_user.in?(e)
  #       }
  #       @instances.push(@instance)
  #     end
  #     e.instances.each do |i|
  #       if i.ends_at > Time.zone.now && !@mobile_user.out?(i)
  #         @instance = {
  #           :iid => i.id,
  #           :gcnt => i.guests.count,
  #           :start => i.starts_at,
  #           :end => i.ends_at,
  #           :address => i.address,
  #           :plan => @mobile_user.in?(i)
  #         }
  #         @instances.push(@instance)
  #       end
  #     end
  #     @temp = {
  #       :eid => e.id,
  #       :title => e.title,  
  #       :start => e.starts_at,#don't do timezone here, do it local on mobile
  #       :end => e.ends_at, 
  #       :gcnt => e.guests.count,  
  #       :tip => e.min,
  #       :image => e.image(:medium), 
  #       :host => e.user,
  #       :plan => @mobile_user.rsvpd?(e),
  #       :tipped => e.tipped,
  #       :gids => @guestids,
  #       :g_share => @g_share,
  #       :share_a => @mobile_user.invited_all_friends?(e),
  #       :ot => e.one_time,
  #       :pub => e.is_public
  #     }
  #     @list_events.push(@temp)
  #   end 
  #   render json: @list_events
  # end
end
