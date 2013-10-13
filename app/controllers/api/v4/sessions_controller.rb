class Api::V4::SessionsController < Devise::SessionsController
  # Other code

  def create
    warden.authenticate!(:scope => resource_name, :store => false, :recall => "#{controller_path}#failure")
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :data => { :auth_token => current_user.authentication_token } }
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :store => false, :recall => "#{controller_path}#failure")
    current_user.reset_authentication_token!
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }
  end

  # Other code
end