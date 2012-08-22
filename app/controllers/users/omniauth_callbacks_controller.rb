class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    oauthorize "Facebook"
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
private

  def oauthorize(kind)
    @user = find_for_oauth(kind, env["omniauth.auth"], current_user)
    if @user
      #put a flash into the session
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind

      #get shortlived access token, exchange it for a long lived one, save it in the session.
      @short_token = env["omniauth.auth"].credentials.token
      @long_token = HTTParty.get("https://graph.facebook.com/oauth/access_token?client_id=327936950625049&client_secret=4d3de0cbf2ce211f66733f377b5e3816&grant_type=fb_exchange_token&fb_exchange_token=#{@short_token}")
      
      #get back "access_token=AAAEqQcVzYxkBAFPwIFPN7sUsdNZA5gZBIzZCRVbufmkJMlK2OOlITw6cmeZAFgRkrnvVfrCAwG9zZCKDfQRHe163UZAuPhsHUZD&expires=5181597"
      session[:access_token] = @long_token.split('=')[1].split('&')[0]

      # session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = 'There was an error with Facebook. Try signing up through Calenshare.'
      redirect_to new_user_registration_url
    end   
  end

  def find_for_oauth(provider, access_token, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, {}
    case provider
    when "Facebook"
      uid = access_token.uid
      email = access_token.info.email
      session[:access_token] = access_token.credentials.token
      auth_attr = { :uid => uid, :token => access_token.credentials.token, :secret => nil }
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
    if auth.nil?
      auth = user.authentications.build(:provider => provider)
      user.authentications << auth
    end
    auth.update_attributes auth_attr
    
    return user
  end

  def find_for_oauth_by_uid(uid, access_token, resource=nil)
    user = nil
    if auth = Authentication.find_by_uid(uid.to_s)
      user = auth.user
    end
    return user
  end

  def find_for_oauth_by_email(email, access_token, resource=nil)
    if user = User.find_by_email(email)
      return user
    else
      email = access_token.info.email
      name = access_token.info.name
      user = User.new(:email => email, 
                :name => name,
                :terms => true,
                :remember_me => true,
                :password => Devise.friendly_token[0,20]
              ) 
      user.save
      return user
    end
  end
  
  # def find_for_oauth_by_name(name, resource=nil)
  #   if user = User.find_by_name(name)
  #     user
  #   else
  #     user = User.new(:name => name, :password => Devise.friendly_token[0,20], :email => "#{UUIDTools::UUID.random_create}@host")
  #     user.save false
  #   end
  #   return user
  # end
end
