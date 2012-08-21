class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :adjust_format_for_iphone

  def after_sign_in_path_for(resource)
  	if session[:access_token] != nil 
  		@graph = Koala::Facebook::API.new(session[:access_token])
  		@friends = @graph.get_connections('me','friends',:fields => "name,picture,location")
  		@me = @graph.get_object('me')
  		@city_friends = @friends.select { |friend| friend['location'].present? && friend['location']['name'] == @me['location']['name'] }
      @fb_authentications = Authentication.where('uid IN (?)', @city_friends.map {|friend| friend['id']} )
      @city_members = []
      @fb_authentications.each do |fa|
        @city_members.push(fa.user)
      end
      if current_user.authentications.where(:provider == "Facebook") and current_user.sign_in_count == 1  and @city_members.any? == true
    	 find_friends_path
      else
    	home_path
      end
    else
      home_path
    end
  end

  #rescue_from Koala::Facebook::APIError, :with => :expired_token

  private

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
