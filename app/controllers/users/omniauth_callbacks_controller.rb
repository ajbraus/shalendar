class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Facebook"
      auth = request.env['omniauth.auth']
      token = auth['credentials']['token']
      fb_picture = auth['picture']
      # @user.fb_token = token 
      # @user.fb_picture = fb_picture
      # @user.save
      session[:fb_access_token] = token
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = 'Your email already exists. Try signing in through Calenshare.'
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_session_url
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end