class InvitationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  	@user = User.find(params[:invitation][:invited_user_id])
    @event = Event.find(params[:invitation][:invited_event_id])

    current_user.invite!(@event, @user)

    respond_to do |format|
      @invited_users = @event.invited_users - @event.guests
      Notifier.delay.invitation(@event, @user, current_user)
      
      format.html { redirect_to @event }
      @friends = current_user.followers

      format.js
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
  end

  def invite_all_friends 
    
  end

  def invite_all_fb_friends
  end


end