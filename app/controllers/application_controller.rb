class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(resource)
    if current_user.uid != nil && current_user.sign_in_count == 1
    	find_friends_path
    else
    	home_path
    end
  end
end
