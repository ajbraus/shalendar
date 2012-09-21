class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  	@user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:invited_event_id])

    current_user.invite!(@event, @user)

    respond_to do |format|
      @invited_users = @event.invited_users - @event.guests
      
      format.html { redirect_to @event }
      @friends = current_user.followers

      format.js
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
  end

end