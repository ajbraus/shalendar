class StaticPagesController < ApplicationController
  
  def landing
    @cities = City.all
    if session[:current_time_zone].nil?
      @time_in_zone = Time.now.in_time_zone("Central Time (US & Canada)")
    else
      @time_in_zone = Time.now.in_time_zone(session[:current_time_zone])
    end
    @ideas = Event.where('is_big_idea = ? AND starts_at > ?', true, Time.now).sort_by{|i| -i.guests.count}[0..3]
  end

  def about
  	@user = current_user
  end
  def contact
  	@user = current_user
  end
  
  def vendor_splash
  end

  def terms
  end

  def privacy
  end

  def acceptable_use
  end

end
