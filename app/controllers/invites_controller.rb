class InvitesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @event = Event.find(params[:event_id])
    @invite = @event.invites.build(params[:invite])
    @invite.inviter_id = current_user.id 

    respond_to do |format|
      if @invite.save
        #Resque.enqueue(MailerCallback, "Notifier", :invitation, @invite.id, @event.id)
        Notifier.invitation(@invite, @event).deliver
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
    @invite = Invite.find(params[:id])
    @event = Event.find(params[:event_id])
    @invite.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.json { head :no_content }
    end
  end
end