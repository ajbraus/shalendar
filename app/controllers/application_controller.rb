class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :adjust_format_for_iphone
  before_filter :set_time_zone 
  

  def after_sign_in_path_for(resource)
    home_path
  end

  #rescue_from Koala::Facebook::APIError, :with => :expired_token

  private

  def set_time_zone
    if current_user
      Time.zone = current_user.time_zone if current_user.time_zone
    end
  end

  
  # def expired_token
  #   flash[:notice] = "There was an error with Facebook."
  # end

  def adjust_format_for_iphone    
    request.format = :ios if ios_user_agent?
  end
  
  def ios_user_agent?
      request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
end
