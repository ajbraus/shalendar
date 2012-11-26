class StaticPagesController < ApplicationController
  
  def landing
    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
    end
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
