class StaticPagesController < ApplicationController
  
  def landing
    @ideas = Event.where('is_public = ? AND ends_at > ?', true, Time.now).sort_by{|i| -i.guest_count}[0..4]
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
