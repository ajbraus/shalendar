class FbInvitesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    if current_user.permits_wall_posts?(session[:graph]) == true      
      @event = Event.find(params[:event_id])
      @fb_invite = @event.fb_invites.build(params[:fb_invite])
      @fb_invite.save
      if Rails.env.production?
        session[:graph].delay.put_connections( @fb_invite.uid, "feed", {
                                        :name => @event.title,
                                        :link => "http://www.hoos.in/events/#{@event.id}",
                                        :picture => @event.promo_img.url(:medium)
                                      })
      else
        session[:graph].put_connections( 2232003, "feed", {
                                        :name => @event.title,
                                        :link => "http://www.hoos.in/events/#{@event.id}",
                                        :picture => @event.promo_img.url(:medium)
                                      })
      end
      @invite_friends = current_user.fb_friends(session[:graph])[1].reject { |inf| FbInvite.find_by_uid(inf['uid'].to_s) }
      @fb_invites = @event.fb_invites
      @invited_users = @event.invited_users - @event.guests
      respond_to do |format|
        format.html { redirect_to @event, notice: 'fb_invite was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
        format.js
      end
    else 
      respond_to do |format|
        format.html { redirect_to @event, notice: 'fb_invite could not be saved.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.js { render template: "fb_invites/extend_permissions" }
      end
    end
  end

  def invite_all_fb_friends
    if current_user.permits_wall_posts?(session[:graph]) == true  
      @event = Event.find_by_id(params[:id])
      @invite_friends = current_user.fb_friends(session[:graph])[1].reject { |inf| FbInvite.find_by_uid(inf['uid'].to_s) }
      @invite_friends.each do |inf|
        if Rails.env.production?
          @invite_friends.each do |inf|
          session[:graph].delay.put_connections( inf['id'], "feed", {
                                          :name => event.title,
                                          :link => "http://www.hoos.in/events/#{event.id}",
                                          :picture => event.promo_img.url(:medium)
                                        })
          @fb_invite = @event.fb_invite.build({ inviter_id: current_user.id,
                                   fb_pic_url: inf['pic_square'],
                                   name: inf['name'],
                                   uid: f['uid']
                                   })
          @fb_invite.save
          end
        else
          session[:graph].put_connections( 2232003, "feed", {
                                          :name => @event.title,
                                          :link => "http://www.hoos.in/events/#{event.id}",
                                          :picture => event.promo_img.url(:medium)
                                        })
          @fb_invite = @event.fb_invite.build({ inviter_id: current_user.id,
                         fb_pic_url: "http://profile.ak.fbcdn.net/hprofile-ak-snc6/273474_2232003_1306108555_q.jpg",
                         name: "Michael Fenchel",
                         uid: 2232003
                         })
          @fb_invite.save
        end
      end
      @invite_friends = current_user.fb_friends(session[:graph])[1].reject { |inf| FbInvite.find_by_uid(inf['uid'].to_s) }
      @fb_invites = @event.fb_invites
      @invited_users = @event.invited_users - @event.guests
      respond_to do |format|
        format.html { redirect_to @event, notice: 'fb_invite was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
        format.js
      end
    else 
      respond_to do |format|
        format.html { redirect_to @event, notice: 'fb_invite could not be saved.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.js { render template: "fb_invites/extend_permissions" }
      end
    end
  end

  def destroy
    @fb_invite = FbInvite.find_by_id(params[:id])
    @fb_invite.destroy
  end
end