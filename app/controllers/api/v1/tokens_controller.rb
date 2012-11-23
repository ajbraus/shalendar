class Api::V1::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    if params[:access_token]
      # Handle login from mobile FB
      # don't need to do the email confirmation.. they won't have FB access unless they're the right user
      # if params[:email].nil?
      #   render :status=>400,
      #          :json=>{:error=>"The request must contain the user email and FB access token."}
      #   return
      # end
      # email = params[:email]
      if params[:fbid].nil?
         render :status=>400,
                :json=>{:error=>"The request must contain the user FBID"}
         return
      end
      fbid = params[:fbid]
      # email_handle = params[:email].slice('@')
      fb_json = HTTParty.get("https://graph.facebook.com/#{fbid}?access_token=#{params[:access_token]}")
      
      # if email != fb_json["email"]
      #   render :json=>{:error => "Email doesn't match the facebook email"}
      #   return
      # end
      logger.info("the FBID is: #{fbid}")
      @user = find_for_oauth("Facebook", fb_json, params[:access_token])   

      if @user.nil?
        #I think we get the long access token already on the mobile app
        # @short_token = access_token
        # @long_token = HTTParty.get("https://graph.facebook.com/oauth/access_token?client_id=327936950625049&client_secret=4d3de0cbf2ce211f66733f377b5e3816&grant_type=fb_exchange_token&fb_exchange_token=#{@short_token}")
        # access_token = @long_token

        #create a new user from the FB access token + email
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



        # render :status=>402, :json=>{error: "Invalid email/password combination. If you have not yet registered for hoos.in, you have to do so either through facebook or on the website to use the app. Sorry for the inconvenience!"}
        # return
      end
      # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
      @user.ensure_authentication_token!
      if not @user.valid_password?(password)
        render :status=>400, :json=>{:error =>"Invalid email or password."}
        return
      end
    end
    #Turn this into invitations... **UPDATE
    @all_email_invites = EmailInvite.where("email_invites.email = :current_user_email", current_user_email: @user.email)
    @email_invites = []
    @all_email_invites.each do |i|
      @temp = {
        :eid => i.event_id,
        :i => User.find_by_id(i.inviter_id)
      }
      @email_invites.push(@temp)
    end
    render :status=>200, :json=>{:token=>@user.authentication_token, 
                                  :user=>{
                                    :user_id=>@user.id,
                                    :first_name=>@user.first_name,
                                    :last_name=>@user.last_name,
                                    :myself=>@user,
                                    :email_hex=> Digest::MD5::hexdigest(@user.email.downcase),
                                    :confirm_f=>@user.require_confirm_follow,
                                    :daily_d=>@user.allow_contact,
                                    :notify_r=>@user.notify_event_reminders,
                                    :post_wall=>@user.post_to_fb_wall,
                                    :followed_users=>@user.followed_users,#may put these in separate calls for speed of login
                                    :pending_followed_users=>@user.pending_followed_users,
                                    #:followers=>@followers,
                                    :invites=>@invites
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
      uid = fb_info[:id]
      email = fb_info[:email]
      token = access_token
      @graph = Koala::Facebook::API.new
      pic_url = @graph.get_picture(uid)
      auth_attr = { :uid => uid, :token => token, :secret => nil, :pic_url => pic_url }
    else
      raise 'Provider #{provider} not handled'
    end
    if resource.nil?
      if email
        user = find_for_oauth_by_email(email, fb_info, resource)
      else 
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
             # TURN ALL FB_INVITES INTO INVITIATTIONS HERE 
    FbInvite.where("uid = ?", uid).each do |fbi|
      @inviter_id = fbi.inviter_id
      @invited_user_id = user.id
      @event = fbi.event
      if @inviter = User.find_by_id(@inviter_id)
        @inviter.invite!(@event, user)
      end
      fbi.destroy
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
      email = fb_info[:email]
      name = fb_info[:name]
      location = fb_info[:location][:name]
      @city = City.find_by_name(location)
      if @city.nil?
        c = City.new(name: location, timezone: "Central Time (US & Canada)")#timezone_for_utc_offset(access_token.extra.raw_info.timezone)
        c.save
        @city = c
      end

      time_zone = "Central Time (US & Canada)" #timezone_for_utc_offset(access_token.extra.raw_info.timezone)

      user_attr = { email: email, name: name, city: location, time_zone: time_zone }
      user.update_attributes user_attr
      
      return user

    else
      email = fb_info.email
      name = fb_info.name
      city = fb_info.location
      time_zone = "Central Time (US & Canada)"  # timezone_for_utc_offset(access_token.extra.raw_info.timezone)

      user = User.new(:email => email, 
                :name => name,
                :city => city,
                :time_zone => time_zone,
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
    elsif @user.iPhone_user == true && @user.APNtoken == token
      render status: 200, :json => { :success => true }
      return
    end
    logger.info("the token is: #{token}")

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

    # n = APN::Notification.new
    # n.device = APN::Device.find_by_id(@user.apn_device_id)
    # n.sound = true
    # n.badge = 1
    # n.alert = "you have registered for push"
    # n.save

    render :json => { :success => true, :token => token }
  end

  def gcm_user
    @user = User.find_by_id(params[:user_id])

    logger.info("Registration id: #{params[:registration_id]}")
    registration_id = params[:registration_id]
    if @user.android_user == true && @user.GCMtoken == registration_id
      render :json => { :success => true }
        notification = Gcm::Notification.new
        notification.device = Gcm::Device.find(@user.GCMdevice_id)
        notification.collapse_key = "updates_available"
        notification.delay_while_idle = true
        notification.data = {:registration_id => registration_id, :data => {:message_text => "Happy afternoon!"}}
        notification.save
      return
    end
    device = Gcm::Device.new
    device.registration_id = registration_id

    #create(registration_id: registration_id)
    device.save!
    
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = "updates_available"
    notification.delay_while_idle = true
    notification.data = {:registration_id => registration_id, :data => {:message_text => "Happy afternoon!"}}
    notification.save

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

