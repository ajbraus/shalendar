class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    oauthorize "Facebook"
  end
  
  def twitter
    oauthorize "Twitter"
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
private

  def oauthorize(kind)
    @user = find_for_oauth(kind, env["omniauth.auth"], current_user)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      @user.remember_me = true
      @user.terms = true
      session[:access_token] = Koala::Facebook::OAuth.new(oauth_redirect_url).exchange_access_token(params[:code]) if params[:code]
      session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = 'There was an error with Facebook. Try signing up through Calenshare.'
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end   
  end

  def find_for_oauth(provider, access_token, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, {}
    case provider
    when "Facebook"
      uid = access_token.uid
      email = access_token.info.email
      name = access_token.name
      auth_attr = { :uid => uid, :token => access_token.credentials.token, :secret => nil, :name => name, :link => access_token.info.link }
    when "Twitter"
      uid = access_token['extra']['info']['id']
      name = access_token['user_info']['name']
      auth_attr = { :uid => uid, :token => access_token['credentials']['token'], :secret => access_token['credentials']['secret'], :name => name, :link => "http://twitter.com/#{name}" }
    when 'LinkedIn'
      uid = access_token['uid']
      name = access_token['user_info']['name']
      auth_attr = { :uid => uid, :token => access_token['credentials']['token'], :secret => access_token['credentials']['secret'], :name => name, :link => access_token['user_info']['public_profile_url'] } 
    else
      raise 'Provider #{provider} not handled'
    end
    if resource.nil?
      if email
        user = find_for_oauth_by_email(email, resource)
      elsif uid && name
        user = find_for_oauth_by_uid(uid, resource)
        if user.nil?
          user = find_for_oauth_by_name(name, resource)
        end
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

  def find_for_oauth_by_uid(uid, resource=nil)
    user = nil
    if auth = Authentication.find_by_uid(uid.to_s)
      user = auth.user
    end
    return user
  end

  def find_for_oauth_by_email(email, resource=nil)
    if user = User.find_by_email(email)
      user
    else
      user = User.new(:email => email, :password => Devise.friendly_token[0,20]) 
      user.save
    end
    return user
  end
  
  def find_for_oauth_by_name(name, resource=nil)
    if user = User.find_by_name(name)
      user
    else
      user = User.new(:name => name, :password => Devise.friendly_token[0,20], :email => "#{UUIDTools::UUID.random_create}@host")
      user.save false
    end
    return user
  end
end
