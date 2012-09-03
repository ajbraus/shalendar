class Api::V1::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    if params[:access_token]
      # Handle login from mobile FB
      email = params[:email]
      # email_handle = params[:email].slice('@')
      # auth = HTTParty.get("https://graph.facebook.com/#{email_handle}/access_token?#{params[:access_token]}")
      # email = auth.info.email
      # uid = auth.uid
      # provider = auth.provider
      # access_token = params[:access_token]
      # auth_attr = { :uid => uid, :token => access_token, :secret => nil }

      if params[:email].nil?
         render :status=>400,
                :json=>{:message=>"The request must contain the user email and FB access token."}
         return
      end
      # @user = find_for_oauth(email, access_token, resource)
      @user = User.find_by_email(params[:email])

      if @user.present?
        #I think we get the long access token already on the mobile app
        #@short_token = access_token
        #@long_token = HTTParty.get("https://graph.facebook.com/oauth/access_token?client_id=327936950625049&client_secret=4d3de0cbf2ce211f66733f377b5e3816&grant_type=fb_exchange_token&fb_exchange_token=#{@short_token}")
        #access_token = @long_token
      else 
        #create a new user from the FB access token + email
        render :status=>400, :json=>{:message=>"There was an error. Check your Facebook account status and retry."}
        returnx
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
                :json=>{:message=>"The request must contain the user email and password."}
         return
      end
      @user=User.find_by_email(email.downcase)
      logger.info("User #{@user.id} found.")
      if @user.nil?
        logger.info("User #{email} failed signin, user cannot be found.")
        render :status=>401, :json=>{:message=>"Invalid email or passoword."}
        return
      end
      # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
      @user.ensure_authentication_token!
      if not @user.valid_password?(password)
        logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
        render :status=>401, :json=>{:message=>"Invalid email or password."}
        return
      end
    end

    @all_invites = Invite.where("invites.email = :current_user_email", current_user_email: @user.email)
    @invites = []
    @all_invites.each do |i|
      @temp = {
        :eid => i.event_id,
        :i => User.find_by_id(i.inviter_id)
      }
      @invites.push(@temp)
    end

    render :status=>200, :json=>{:token=>@user.authentication_token, 
                                  :user=>{
                                    :user_id=>@user.id,
                                    :first_name=>@user.first_name,
                                    :last_name=>@user.last_name,
                                    :email_hex=> Digest::MD5::hexdigest(@user.email.downcase),
                                    :confirm_f=>@user.require_confirm_follow,
                                    :daily_d=>@user.daily_digest,
                                    :notify_r=>@user.notify_event_reminders,
                                    :notify_n=>@user.notify_noncritical_change,
                                    :post_wall=>@user.post_to_fb_wall,
                                    :followed_users=>@user.followed_users,#may put these in separate calls for speed of login
                                    #:followers=>@followers,
                                    :invites=>@invites
                                    }
                                 }
  end

  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

  def find_for_oauth(provider, access_token, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, {}
    case provider
    when "Facebook"
      uid = access_token.uid
      email = access_token.info.email
      access_token = access_token.credentials.token
      auth_attr = { :uid => uid, :token => access_token, :secret => nil }
    else
      raise 'Provider #{provider} not handled'
    end
    if resource.nil?
      if email
        user = find_for_oauth_by_email(email, access_token, resource)
      else uid
        user = find_for_oauth_by_uid(uid, access_token, resource)
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

  def find_for_oauth_by_email(email, access_token)
    if user = User.find_by_email(email)
      return user
    else
      email = access_token.info.email
      name = access_token.info.name
      city = access_token.info.location
      user = User.new(:email => email, 
                :name => name,
                :city => city,
                :terms => true,
                :remember_me => true,
                :password => Devise.friendly_token[0,20]
              ) 
      user.save
      return user
    end
  end

  def newAPNtoken
    token = params[:apn_token]
    device = APN::Device.create(:token => "XXXX XXXX XXXXX XXXX XXXX .... XXXX")   
    
    notification = APN::Notification.new   
    notification.device = device   
    notification.badge = 5   
    notification.sound = true   
    notification.alert = "My first push"   
    notification.save  

  end

  def newGCMtoken
    token = params[:gcm_token]


  end
end

