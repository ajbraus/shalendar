class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  	@user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:invited_event_id])

    current_user.invite!(@event, @user)

    respond_to do |format|
      @invited_users = @event.invited_users - @event.guests
      @invite_friends = current_user.fb_friends(session[:graph])[1]
      @friends = current_user.followers
      @graph = session[:graph]
      if @graph
        @fb_invites = @event.fb_invites
      end
      Notifier.delay.invitation(@event, @user, current_user)
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
  end
end