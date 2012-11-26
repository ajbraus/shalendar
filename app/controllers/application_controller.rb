class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone, :check_venue_card
  after_filter :store_location

  def store_location
    session[:previous_urls] ||= []
    # store unique urls only
    session[:previous_urls].prepend request.fullpath if session[:previous_urls].first != request.fullpath && request.fullpath != "/payment" && request.fullpath != "/venue" && request.fullpath != "/new_vendor" && request.fullpath != "/user" && request.fullpath != "/user/login" && request.fullpath != "/" && request.fullpath != "/user/logout" && request.fullpath != "/user/join" && request.fullpath != "/user/auth/facebook/callback"
    # For Rails < 3.2
    # session[:previous_urls].unshift request.fullpath if session[:previous_urls].first != request.fullpath 
    session[:previous_urls].pop if session[:previous_urls].count > 3
  end

  def after_sign_in_path_for(resource) 
    @url = session[:previous_urls].reverse.first

    if current_user.sign_in_count == 1 && current_user.vendor == true
      new_card_path
    elsif @url != nil
      "http://www.hoos.in" + @url
    else
      root_path
    end
  end

  private

  def set_time_zone
    if current_user
      Time.zone = current_user.time_zone if current_user.time_zone
    end
  end
  
  def ios_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  def check_venue_card
    if user_signed_in?
      if current_user.vendor?
        unless current_user.has_valid_credit_card?
          flash[:notice] = "Our records show you must update your credit card data"
        end
      end
    end
  end
end
