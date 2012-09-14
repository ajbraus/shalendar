class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # before_filter :adjust_format_for_iphone
  before_filter :set_time_zone 
  before_filter :get_graph
  # caches_action :get_graph

  #rescue_from Koala::Facebook::APIError, :with => :expired_token
  def get_graph
    if session[:graph].nil?
      session[:graph] = Koala::Facebook::API.new(session[:access_token])
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
end
