class UsersController < ApplicationController
  def show
    @user = User.find_by_slug(params[:id])
    if @user.vendor?     
      @events = @user.events.where("starts_at > :now", now: Time.now).order('starts_at asc')
      @past_events = @user.events.where("starts_at < :now", now: Time.now).order('starts_at asc')
    else
      if user_signed_in?
        @events = @user.plans.where("starts_at > :now", now: Time.now).order('starts_at asc')
        @events = @events.select { |e| e.guests_can_invite_friends? || current_user.invited?(e) }
        @past_events = @user.plans.where("starts_at < :now", now: Time.now).order('starts_at asc')        
        @past_events = @past_events.select { |e| e.guests_can_invite_friends? || current_user.invited?(e) }
      else
        @events = @user.plans.where("starts_at > :now", now: Time.now).order('starts_at asc')
        @past_events = @user.plans.where("starts_at < :now", now: Time.now).order('starts_at asc')
      end
    end
  end
end