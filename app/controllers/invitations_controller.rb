class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:pending_plan_id])
    @event.invite!(@user)
    Notifier.invitation(@user, @event).deliver
  end


  def destroy
    @user = Invitation.find(params[:id]).invited_user
    @event = Invitation.find(params[:id]).pending_plan
    @event.uninvite!(@user)
  end

end