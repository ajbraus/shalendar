class UsersController < ApplicationController
  def show
    @user = User.find_by_slug(params[:id])
    if user_signed_in?
      @my_ideas = @user.events.where(:starts_at => nil, :friends_only => false)
      if current_user.is_inmates_with?(@user) 
        @my_ins = @user.plans.where(:starts_at => nil, :friends_only => false) - @my_ideas
      elsif current_user.is_friends_with?(@user) || @user == current_user
        @my_ins = @user.plans.where(:starts_at => nil) - @my_ideas
      end
      @times = @user.events.where("starts_at > ?", Time.now).order('starts_at ASC')
      @times = @times.select { |e| e.user == current_user || current_user.in?(e) }        
      @past_times = @user.events.where("starts_at < ?", Time.now).order('starts_at ASC').limit(20)
      @past_times = @past_times.select { |e| e.user == current_user || current_user.in?(e) }        
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