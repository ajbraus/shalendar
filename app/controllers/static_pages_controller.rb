class StaticPagesController < ApplicationController
  
  def landing
    if session[:current_time_zone].nil?
      Time.now = Time.now.in_time_zone("Central Time (US & Canada)")
    else
      Time.now = Time.now.in_time_zone(session[:current_time_zone])
    end
    @ideas = Event.where(:is_public => true).sort_by{|i| -i.guests.count}[0..4]
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
