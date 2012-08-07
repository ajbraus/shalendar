class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(resource)
  	if session[:fb_access_token] != nil
      @access_token = session[:fb_access_token]
  		@graph = Koala::Facebook::API.new(@access_token)
  		@friends = @graph.get_connections('me','friends',:fields => "name,picture,location")
  		@me = @graph.get_object('me')
  		@city_friends = @friends.select { |friend| friend['location'].present? && friend['location']['name'] == @me['location']['name'] }
      if current_user.uid != nil && current_user.sign_in_count == 1  && @city_friends != nil
    	 find_friends_path
      else
    	home_path
      end
    else
      home_path
    end
  end
end
