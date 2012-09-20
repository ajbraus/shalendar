class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  	@user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:invited_event_id])

    current_user.invite!(@event, @user)

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  end