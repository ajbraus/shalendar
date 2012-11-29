class CategorizationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @event = Event.find(params[:rsvp][:plan_id])
    current_user.rsvp!(@event)
    if @event.guests.count == @event.min && @event.tipped? == false
      @event.tip!
    end

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    current_user.categorizations.find_by_category_id(params[:category_id])

    @event = Rsvp.find(params[:id]).plan
    current_user.unrsvp!(@event)

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end