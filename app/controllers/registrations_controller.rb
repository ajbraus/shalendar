class RegistrationsController < Devise::RegistrationsController

  def new
    @cities = City.all
    super
  end

  def create
    build_resource
    if resource.save
      #turn all email_invites into invitations here **UPDATE
      EmailInvite.where("email_invites.email = :new_user_email", new_user_email: resource.email).each do |ei|
        @inviter_id = ei.inviter_id
        @invited_user_id = resource.id
        @event = ei.event
        if @inviter = User.find_by_id(@inviter_id)
          @inviter.invite!(@event, resource)
        end
        ei.destroy
      end


      Category.all.each do |cat|
        Interest.create(user_id: resource.id, category_id: cat.id)
      end

      if params[:category_id]
        resource.classification_id = params[:category_id]
      end


      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

	def edit
    @cities = City.all
		@graph = session[:graph]		
		super
	end
  
  def update
  	@graph = session[:graph]
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    #update city if user is changing city
    if params[:resource]
      if params[:resource][:city_id]
        resource.city = City.find_by_id(params[:resource][:city_id])
        resource.save
      end
    end

    #update interests if changing interests
    if params[:category_ids]
      resource.interests.each do |interest|
        interest.destroy
      end
      params[:category_ids].each do |catid|
        Interest.create(user_id: resource.id, category_id: catid)
      end
      #redirect_to root_path, :notice => "Successfully updated your interests"
    end        

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
      respond_with resource, :location => root_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def new_vendor
    sign_out current_user
    session[:graph] = nil if session[:graph].present?

    @cities = City.all
    resource = build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end