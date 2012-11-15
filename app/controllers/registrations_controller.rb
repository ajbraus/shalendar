class RegistrationsController < Devise::RegistrationsController

  def new
    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
    end
    super
  end

  def create
    build_resource
    
    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
    end

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

      if resource.active_for_authentication?
        if params[:vendor]
          sign_in(resource_name, resource)
          redirect_to credit_card_path
          #respond_with resource, :location => after_vendor_sign_up_path_for(resource)
        end
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
    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
    end

		@graph = session[:graph]		
		super
	end
  
  def update
  	@graph = session[:graph]
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
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
    sign_out(current_user)

    @all_cities = City.all
    @cities = []
    @all_cities.each do |c|
      @city_name = c.name
      @cities.push(@city_name)
    end
    resource = build_resource({})
    respond_with resource
  end
end