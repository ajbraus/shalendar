class Api::V2::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    if params[:access_token]
      if params[:fbid].nil?
         render :status=>400,
                :json=>{:error=>"The request must contain the user FBID"}
         return
      end
      fbid = params[:fbid]
      fb_json = HTTParty.get("https://graph.facebook.com/#{fbid}?access_token=#{params[:access_token]}")
      @user = find_for_oauth("Facebook", fb_json, params[:access_token])   
      if @user.nil?
        render :status=>400, :json=>{:error=>"There was an error. Please check your Facebook account status and retry."}
        return
      end
    else
      email = params[:email]
      password = params[:password]
      if request.format != :json
        render :status=>406, :json=>{:message=>"The request must be json"}
        return
      end
      if email.nil? or password.nil?
         render :status=>400,
                :json=>{:error =>"The request must contain the user email and password."}
         return
      end
      @user=User.find_by_email(email.downcase)
      if @user.nil? #create a new user
        render :status=>402, :json=>{error: "Invalid email/password combination. If you have not yet registered for hoos.in, you have to do so either through facebook or at www.hoos.in. Sorry for the inconvenience!"}
        return
      end
      @user.ensure_authentication_token!
      if not @user.valid_password?(password)
        render :status=>400, :json=>{:error =>"Invalid email or password."}
        return
      end
    end
    @starred_ids = []
    @user.friends.each do |f|
      @starred_ids.push(f.id)
    end
    render :status=>200, :json=>{:token=>@user.authentication_token, 
                                  :user=>{
                                    :user_id=>@user.id,
                                    :first_name=>@user.first_name,
                                    :last_name=>@user.last_name,
                                    :myself=>@user,
                                    :email_hex=> Digest::MD5::hexdigest(@user.email.downcase),
                                    :friends=>@user.inmates | @user.friends,
                                    :city_name=>@user.city.name,
                                    :starred_ids => @starred_ids
                                    }
                                  }
  end

  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:error=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

  def find_for_oauth(provider, fb_info, access_token, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, nil, {}
    case provider
    when "Facebook"
      logger.info("#{fb_info}")
      uid = fb_info["id"]
      email = fb_info["email"]
      token = access_token
      @graph = Koala::Facebook::API.new
      pic_url = @graph.get_picture(uid)
      auth_attr = { :uid => uid, :token => token, :secret => nil, :pic_url => pic_url }
    else
      raise 'Provider #{provider} not handled'
    end
    if resource.nil?
      user = find_for_oauth_by_email(email, fb_info, resource)
      if email.present? && user.nil?
        user = find_for_oauth_by_uid(uid, fb_info, resource)
      end
    else
      user = resource
    end
    
    auth = user.authentications.find_by_provider(provider)
    if auth.nil? && Authentication.find_by_uid(uid).nil?     
      auth = user.authentications.build(:provider => provider)
      user.authentications << auth
    end
    if auth.present?
      auth.update_attributes auth_attr
    end

    if auth.nil?
      user = nil
    end

    return user
  end

  def find_for_oauth_by_uid(uid, fb_info, resource=nil)
    user = nil
    if auth = Authentication.find_by_uid(uid.to_s)
      user = auth.user
    end
    return user
  end

  def find_for_oauth_by_email(email, fb_info, resource=nil)
    if user = User.find_by_email(email)
      email = fb_info["email"]
      name = fb_info["name"]
      location = "Madison, Wisconsin"
      unless fb_info["location"].nil?
        location = fb_info["location"]["name"]
      end
      @city = City.find_by_name(location)
      if @city.nil?
        c = City.new(name: location, timezone: "Central Time (US & Canada)")#timezone_for_utc_offset(access_token.extra.raw_info.timezone)
        c.save
        @city = c
      end

      user_attr = { email: email, name: name, city: @city}
      user.update_attributes user_attr
      
      return user

    else
      email = fb_info["email"]
      name = fb_info["name"]
      city = fb_info["location"]["name"]
      time_zone = "Central Time (US & Canada)"  # timezone_for_utc_offset(access_token.extra.raw_info.timezone)

      user = User.new(:email => email, 
                :name => name,
                :city => city,
                :terms => true,
                :remember_me => true,
                :password => Devise.friendly_token[0,20]
              )
      user.save
      EmailInvite.where("email_invites.email = :new_user_email", new_user_email: user.email).each do |ei|
        @inviter_id = ei.inviter_id
        @invited_user_id = user.id
        @event = ei.event
        if @inviter = User.find_by_id(@inviter_id)
          @inviter.invite!(@event, user)
        end
        ei.destroy
      end
      return user
    end
  end

  def apn_user
    token = params[:apn_token]
    @user = User.find_by_id(params[:user_id])

    if @user.nil?
      render status: 400, :json => { :error => "user could not be found." }
      return
    # elsif @user.iPhone_user == true && @user.APNtoken == token
    #   render status: 200, :json => { :success => true }
    #   return
    end

    #do a more robust check to make sure we don't use same id and same token ever,
    #and that we shouldn't make extra devices
    device = APN::Device.find_by_token(token)
    if device.nil?
      device = APN::Device.new
      device.token = token
      device.save!
    end
    @user.APNtoken = token
    @user.iPhone_user = true
    @user.apn_device_id = device.id
    @user.save!

    render :json => { :success => true, :token => token }
  end

  def gcm_user
    @user = User.find_by_id(params[:user_id])

    logger.info("Registration id: #{params[:registration_id]}")
    
    registration_id = params[:registration_id]
    if @user.nil?
      render status: 400, :json => { :error => "user could not be found." }
      return
    # if @user.android_user == true && @user.GCMtoken == registration_id
    #   render :json => { :success => true }
    #   return
    end

    # device = Gcm::Device.new
    # device.registration_id = registration_id
    # device.save!
    device = Gcm::Device.find_by_registration_id(registration_id)
    if device.nil?
      device = Gcm::Device.create(:registration_id => registration_id)
      device.save
    end
    # notification = Gcm::Notification.new
    # notification.device = device
    # notification.collapse_key = "updates_available"
    # notification.delay_while_idle = true
    # notification.data = {:registration_ids => [registration_id], :data => {:message_text => "Happy afternoon!"}}
    # notification.save

    @user.GCMtoken = registration_id
    @user.GCMdevice_id = device.id
    @user.android_user = true
    if @user.save!
      render :json => {:success => true }
    else
      render :status => 400, :json => {:error => "user did not save"}
    end
  end
end

