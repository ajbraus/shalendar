class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_city, :set_time_zone, :set_graph #:check_venue_card, 
  after_filter :store_location

  def store_location
    session[:previous_urls] ||= []
    # store unique urls only
    session[:previous_urls].prepend request.fullpath if session[:previous_urls].first != request.fullpath && request.fullpath != "/user/sign_up" && request.fullpath != "/everywhere_else" && request.fullpath != "/payment" && request.fullpath != "/venue" && request.fullpath != "/new_vendor" && request.fullpath != "/user" && request.fullpath != "/user/login" && request.fullpath != "/" && request.fullpath != "/user/logout" && request.fullpath != "/user/join" && request.fullpath != "/user/auth/facebook/callback"
    # For Rails < 3.2
    # session[:previous_urls].unshift request.fullpath if session[:previous_urls].first != request.fullpath 
    session[:previous_urls].pop if session[:previous_urls].count > 3
  end

  def after_sign_in_path_for(resource)
    if session[:pervious_urls].present? 
      @url = session[:previous_urls].reverse.first

      if current_user.sign_in_count == 1 && current_user.vendor == true
        new_card_path
      elsif @url != nil
        "http://www.hoos.in" + @url
      else
        root_path
      end
    else
      root_path
    end
  end

  private

  def set_city
    if user_signed_in?
      @current_city = current_user.city
    else
      if params[:city].present?
        @current_city = City.find_by_name(params[:city])
      else
        @current_city = City.find_by_name("Madison, Wisconsin")
      end
    end
  end

  def set_time_zone
    if user_signed_in?
      Time.zone = @current_city.timezone
    elsif session[:city]
      Time.zone = City.find_by_name(session[:city]).timezone
    end
    if Time.zone.nil?
      Time.zone = "Central Time (US & Canada)"
    end
  end

  def set_graph
    if user_signed_in?
      if current_user.authentications.find_by_provider("Facebook").present?
        @graph = session[:graph] 
      else 
        session[:graph] = nil
      end
    else
      @graph = nil
    end
  end
  
  def ios_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  def check_venue_card
    if user_signed_in?
      if current_user.vendor?
        if !current_user.has_valid_credit_card? && current_user.sign_in_count != 1
          flash[:notice] = "Our records show you must update your credit card data"
        end
      end
    end
  end
end
