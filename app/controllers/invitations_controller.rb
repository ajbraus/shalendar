class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  	@user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:invited_event_id])
    current_user.invite!(@event, @user)

    respond_to do |format|
      Notifier.delay.invitation(@event, @user, current_user)
      format.html { redirect_to idea_path(@event) }
      #format.js
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
  end
end