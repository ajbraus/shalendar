class StaticPagesController < ApplicationController
  
  def landing
  end

  def about
  	@user = current_user
  end
  def contact
  	@user = current_user
  end
  
  def vendor_splash
  end

end
