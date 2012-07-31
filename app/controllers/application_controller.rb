class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(resource)
    if current_user.uid != nil
    	find_friends_path
    else
    	user_root_path
    end
  end
end
