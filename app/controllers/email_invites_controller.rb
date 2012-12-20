class EmailInvitesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @event = Event.find(params[:event_id])
    @invite = @event.email_invites.build(params[:email_invite])
    @invite.inviter_id = current_user.id 

    respond_to do |format|
      if @invite.save
        #Resque.enqueue(MailerCallback, "Notifier", :invitation, @invite.id, @event.id)
        #NOTE- we are using Notifier.delay only for msgs that have no mobile push ever
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