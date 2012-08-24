class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def create
    user = User.new(params[:user])
    # user.email = params[:email]
    # user.name = params[:name]
    # user.password = params[:password]
    # user.terms = true

    #userHash = {email: params[:email], name: params[:name], password: params[:password], terms: true}
    #user = User.new(userHash)
    # user.email = params[:email]
    # user.password = params[:password]
    # user.terms = true
    # user.name = params[:name]
    if user.save
      render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status=>422
    end


    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: {"Hello"} }
    # end


  end

	def edit
		@graph = Koala::Facebook::API.new(@access_token)		
		super
	end
  
  def update
  	@graph = Koala::Facebook::API.new(@access_token)	
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.respond_to?(:unconfirmed_email)
      prev_unconfirmed_email = resource.unconfirmed_email 
    end

    #if resource.update_with_password(resource_params)
    if resource.update_attributes(resource_params)	
      # if is_navigational_format?
      #   flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
      #     :update_needs_confirmation : :updated
      #   set_flash_message :notice, flash_key
      # end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => home_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

# A different solution to solve the required confirm password to update profile in devise.

  #   def update
  #   if params[resource_name][:password].blank?
  #     params[resource_name].delete(:password)
  #     params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
  #   end
  #   # Override Devise to use update_attributes instead of update_with_password.
  #   # This is the only change we make.
  #   if resource.update_attributes(params[resource_name])
  #     set_flash_message :notice, :updated
  #     # Line below required if using Devise >= 1.2.0
  #     sign_in resource_name, resource, :bypass => true
  #     redirect_to after_update_path_for(resource)
  #   else
  #     clean_up_passwords(resource)
  #     render_with_scope :edit
  #   end
  # end
end