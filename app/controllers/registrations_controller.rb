class RegistrationsController < Devise::RegistrationsController

# def create
#       if verify_recaptcha
#         super
#       else
#         build_resource
#         clean_up_passwords(resource)
#         flash[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
#         render :new
#       end
#     end

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