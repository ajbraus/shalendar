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
    @invite_friends = []
    @graph = session[:graph]
    @city_friends = @graph.fql_query("SELECT uid, name, pic_square, current_location FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())")
    @city_friends.each do |cf|
      if cf['current_location']
        if cf['current_location']['name'] == current_user.city
          @invite_friends.push(cf)
        end
      end
    end
    @invite_friends.each do |inf|
      if Rails.env.production?
        @invite_friends.each do |inf|
        session[:graph].delay.put_connections( inf['id'], "feed", {
                                        :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                        :name => "hoos.in",
                                        :link => "http://www.hoos.in/",
                                        :caption => "Do Great Things With Friends",
                                        :picture => "http://www.hoos.in/assets/icon.png"
                                      })
        end
      else
        session[:graph].put_connections( 2232003, "feed", {
                                        :message => "I'm using hoos.in to do awesome things with my friends. Check it out:", 
                                        :name => "hoos.in",
                                        :link => "http://www.hoos.in/",
                                        :caption => "Do Great Things With Friends",
                                        :picture => "http://www.hoos.in/assets/icon.png"
                                      })
      end
    end
  end


end