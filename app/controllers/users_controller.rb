class UsersController < ApplicationController
  def show
    @user = User.find_by_slug(params[:id])
    if user_signed_in?
      @my_ideas = @user.events.where(:starts_at => nil)
      @ideas = @my_ideas.select { |e| e.user == current_user || @user.in?(e) }        
      @events = @user.events.where("starts_at > ?", Time.now).order('starts_at asc')
      @events = @events.select { |e| e.user == current_user || @user.in?(e) }        
      @past_events = @user.events.where("starts_at < ?", Time.now).order('starts_at asc').limit(20)
      @past_events = @past_events.select { |e| e.user == current_user || @user.in?(e) }        
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