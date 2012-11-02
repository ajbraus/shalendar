class SuggestionsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @suggestions = current_user.suggestions.where('starts_at IS NOT NULL and starts_at > ?', Time.now).order('starts_at ASC')
  end

  def clone
    @suggestion = Suggestion.find(params[:suggestion_id])
    @clone = @suggestion.events.build(user_id: current_user.id,
                             suggestion_id: @suggestion.id,
                             title: @suggestion.title,
                             starts_at: @suggestion.starts_at,
                             duration: @suggestion.duration,
                             max: @suggestion.max,
                             address: @suggestion.address,
                             latitude: @suggestion.latitude,
                             longitude: @suggestion.longitude,
                             link: @suggestion.link,
                             gmaps: @suggestion.gmaps,
                             guests_can_invite_friends: true,
                             price: @suggestion.price,
                             promo_img: @suggestion.promo_img
                          )
    respond_to do |format|
      #format.html
      format.js
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.json
  # def show
  #   @suggestion = Suggestion.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @suggestion }
  #   end
  # end

  # GET /suggestions/new
  # GET /suggestions/new.json
  def new
    @suggestion = current_user.suggestions.build

    respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @suggestion }
      format.js
    end
  end

  # GET /suggestions/1/edit
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @vendor = current_user
    @suggestion = @vendor.suggestions.build(params[:suggestion])
    
    respond_to do |format|
      if @suggestion.save
        unless @suggestion.starts_at.nil?
          @event = @vendor.events.build(title: @suggestion.title,
                              starts_at: @suggestion.starts_at,
                              ends_at: @suggestion.starts_at + @suggestion.duration*3600,
                              user_id: @vendor.id,
                              min: 1,
                              max: @suggestion.max,
                              duration: @suggestion.duration,
                              tipped: true,
                              link: @suggestion.link,
                              address: @suggestion.address,
                              longitude: @suggestion.longitude,
                              latitude: @suggestion.latitude,
                              gmaps: @suggestion.gmaps,
                              guests_can_invite_friends: true,
                              suggestion_id: @suggestion.id,
                              price: @suggestion.price,
                              promo_img: @suggestion.promo_img
                            )
          @event.save
          @vendor.rsvp!(@event)
        end
        format.html { redirect_to vendor_dashboard_path, notice: 'Suggestion was successfully created.' }
        format.json { render json: vendor_dashboard_path, status: :created, location: @suggestion }
      else
        format.html { redirect_to root_path, notice: 'Suggestion could not be created. Please try again.' }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /suggestions/1
  # PUT /suggestions/1.json
  def update
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      if @suggestion.update_attributes(params[:suggestion])
        format.html { redirect_to vendor_dashboard_path, notice: 'Suggestion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.json
  def destroy
    @suggestion = Suggestion.find(params[:id])
    @suggestion.destroy

    respond_to do |format|
      format.html { redirect_to vendor_dashboard_path, notice: 'Suggestion was successful destroyed' }
      format.json { head :no_content }
    end
  end
end
