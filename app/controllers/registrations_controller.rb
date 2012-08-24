class RegistrationsController < Devise::RegistrationsController

  def create
    super
    #binding.pry
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
end