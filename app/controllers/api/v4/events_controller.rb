class Api::V4::EventsController < ApiController

  def index
    @events = Event.all
    render 'api/events/index'
  end

  def show
    @event = Event.find(params[:id])
    render 'api/events/show'
  end

  def new
    @event = Event.new
  end

  def create
    # [:event][:title, :description, :one_time, :link, :address, :instance_attributes, :promo_img_file_name, :promo_img_content_type]

    @event = current_user.events.build(params[:event])
    @event.link = @event.link.split("http://")[1] if @event.link.present?
    @event.city = @current_city
    @event.instances.each do |i|
      i.city = @event.city
      i.visibility = @event.visibility
    end
    @userfile = params[:event][:promo_img_file_name]
    #logger.info("ADD PHOTO PARAMS: #{params}")
    @userfile.content_type = params[:event][:promo_img_content_type]
    @event.promo_img = @userfile

    if @event.save
      current_user.rsvp_in!(@event)
      @event.instances.each { |i| current_user.rsvp_in!(i) } #INVITATION TO ALL INSTANCES
      @event.save_shortened_url if Rails.env.production? #SAVE SHORTENED URL
      unless @event.visibility == 0 #SEND CONTACT TO ALL PPL WHO STAR CURRENT USER
        current_user.friended_bys.each do |sb|
          sb.delay.contact_new_idea(@event)
        end
      end
      render 'api/events/show'
    else
      #ERROR HASH
    end
  end

  def edit
    expose Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    render 'api/events/show'
  end

  def destroy
    @event = Event.find(params[:id])
    @event.dead = true
    @event.save

    @event.instances.each do |i|
      i.dead = true
      i.save
    end

    g.delay.contact_cancellation(@event)
  end
end