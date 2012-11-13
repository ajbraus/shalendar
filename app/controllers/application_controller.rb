class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone
#   after_filter :store_location

# protected 

#   def after_sign_in_path_for(resource) 
#     session[:previous_urls].reverse.each do |url|
#       unless url == nil
#         redirect_to url
#       else
#         redirect_to root_path
#       end
#     end
#   end


    #redirect_to stored_location_for(:user) || root_path
  #end 

  # def store_location
  #   session[:previous_urls] ||= []
  #   # store unique urls only
  #   session[:previous_urls].prepend request.fullpath if session[:previous_urls].first != request.fullpath && request.fullpath != "/user/login" && request.fullpath != "/user/logout" && request.fullpath != "/user/join"
  #   # For Rails < 3.2
  #   # session[:previous_urls].unshift request.fullpath if session[:previous_urls].first != request.fullpath 
  #   session[:previous_urls].pop if session[:previous_urls].count > 3
  # end

# def after_sign_in_path_for(resource)
#   session[:previous_urls].reverse.each do |url|
#     if url != root_path && url != nil
#       redirect_to url
#       break
#     else
#       redirect_to root_path
#     end
#   end
# end


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
