class UsersController < ApplicationController
  def show
    @user = User.find_by_slug(params[:id])
    if user_signed_in?
      if current_user.is_friends_with?(@user) || @user == current_user
        @my_ins = @user.plans.where('starts_at IS NULL OR (one_time = ? AND ends_at > ?)', true, Time.now)
      else 
        @my_ins = @user.plans.where('friends_only = ? AND starts_at IS NULL OR (one_time = ? AND ends_at > ?)', false, true, Time.now)
      end
      
      @my_ins.sort_by do |i|
          i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count*1000 + 
            i.guests.joins(:relationships).where('status = ? AND follower_id = ?', 1, current_user.id).count
      end

      @times = @user.plans.where("starts_at > ?", Time.now).order('starts_at ASC')        
      @past_times = @user.plans.where("starts_at < ?", Time.now).order('starts_at ASC').limit(20)
    else
      #@events = @user.plans.where("starts_at > :now", now: Time.now).order('starts_at asc')
      #@past_events = @user.plans.where("starts_at < :now", now: Time.now).order('starts_at asc')
    end
  end

  def city_names
    @city_names = City.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @city_names.map(&:name)
  end
end