class FbInvitesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @event = Event.find(params[:event_id])
    @invite = @event.fb_invites.build({uid:  :inviter_id, :fb_pic_url})
    @invite.inviter_id = current_user.id 

    respond_to do |format|
      if @invite.save
        #Resque.enqueue(MailerCallback, "Notifier", :invitation, @invite.id, @event.id)
        Notifier.delay.email_invitation(@invite, @event)
        format.html { redirect_to @event, notice: 'Invite was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
        format.js
      else
        format.html { redirect_to @event, notice: 'Invite could not be saved.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @email_invite = EmailInvite.find_by_id(params[:id])
    @email_invite.destroy
  end
end