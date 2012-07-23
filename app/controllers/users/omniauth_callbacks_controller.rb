class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Facebook"
      auth = request.env['omniauth.auth']
      token = auth['credentials']['token']
      session[:fb_access_token] = token
      if @user.sign_in_count >= 1
        sign_in_and_redirect @user, :event => :authentication
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end