class SuggestionsController < ApplicationController

  def index
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @suggestions = current_user.suggestions.all
  end

  def clone
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @suggestion = Suggestion.find(params[:suggestion_id])
    @clone = @suggestion.events.new(user_id: current_user.id,
                             suggestion_id: @suggestion.id,
                             title: @suggestion.title,
                             starts_at: @suggestion.starts_at,
                             duration: @suggestion.duration,
                             max: @suggestion.max,
                             address: @suggestion.address,
                             latitude: @suggestion.latitude,
                             longitude: @suggestion.longitude,
                             link: @suggestion.link,
                             gmaps: @suggestion.gmaps
                          )
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.json
  def show
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @suggestion }
    end
  end

  # GET /suggestions/new
  # GET /suggestions/new.json
  def new
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @suggestion = Suggestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @suggestion }
    end
  end

  # GET /suggestions/1/edit
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
    @user = current_user
    @suggestion = @user.suggestions.build(params[:suggestion])

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to vendor_dashboard_path, notice: 'suggestion was successfully created.' }
        format.json { render json: vendor_dashboard_path, status: :created, location: @suggestion }
      else
        format.html { render action: "new" }
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
        format.html { redirect_to @suggestion, notice: 'suggestion was successfully updated.' }
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
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
