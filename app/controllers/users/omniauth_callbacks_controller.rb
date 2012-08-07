class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Facebook"
      @user.remember_me = true
      auth = request.env['omniauth.auth']
      token = auth['credentials']['token']
      session[:fb_access_token] = token
      city = auth['info']['location']
      @user.city = city
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = 'There was an error with Facebook. Try signing up through Calenshare.'
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_session_url
    end
  end

  # def twitter
  #   @user = User.find_for_twitter_oauth(env['omniauth.auth'], current_user)

  #   if @user.persisted?
  #     flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Twitter'
  #     @user.remember_me = true
  #     session[:]
  #     sign_in_and_redirect @user, event: :authentication,
  #   else
  #     flash[:notice] = I18n.t 'devise.omniauth_callbacks.failure', kind: 'Twitter', reason: 'User not found'
  #     redirect_to new_user_session_path
  #   end
  # end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

end