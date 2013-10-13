class Api::V4::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token

  respond_to :json
# file: app/controllers/api/v1/registrations_controller.rb
  def create
    build_resource(params[:registration])
    resource.skip_confirmation!
    if resource.save
      sign_in(resource, :store => false)
      render :status => 200,
           :json => { :success => true,
                      :info => "Registered",
                      :data => { :user => resource,
                                 :auth_token => current_user.authentication_token } }
    else
      render :status => :unprocessable_entity,
             :json => { :success => false,
                        :info => resource.errors,
                        :data => {} }
    end
  end
  
  # def create
  #   @user = User.create(params[:user])
    
  #   if @user.save
  #     respond_with @user.as_json(:auth_token=>@user.authentication_token, :email=>@user.email), :status=>201
  #     return
  #   else
  #     warden.custom_failure!
  #     respond_with @user.errors, :status=>422
  #   end
  # end

  def edit
    @graph = session[:graph]  
    super
  end
  
  def update
    @graph = session[:graph]
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.respond_to?(:unconfirmed_email)
      prev_unconfirmed_email = resource.unconfirmed_email 
    end

    #if resource.update_with_password(resource_params)
    if resource.update_attributes(resource_params)  
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => root_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

end