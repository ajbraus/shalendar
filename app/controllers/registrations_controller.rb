class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :pick_city] #added pick_city
  
  def new
    super
  end

  def create
    if City.find_by_name(params[:city_name])
      resource_params[:city] = City.find_by_name(params[:city_name])
    else 
      return redirect_to :back, notice: "City not found - Try a city close to your location"
    end
    build_resource
    if resource.save
      resource.convert_email_invites

      @hoosin_user = User.find_by_email("info@hoos.in")
      if @hoosin_user.present?
        resource.inmate!(@hoosin_user)
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
  
  def update
    #change city name into idco
    @city = City.find_by_name(params[:city_name])
    if @city.present?
      if resource_params.blank?
        resource_params = { "city" => nil }
      end
      resource_params[:city] = @city
    else 
      return redirect_to :back, notice: "City not found - Try the name of a bigger city nearest to you"
    end

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
      if current_user.sign_in_count == 1 && session[:previous_urls].present? 
        @url = session[:previous_urls].reverse.first
        redirect_to @url and return
      else
        sign_in resource_name, resource, :bypass => true
        respond_with resource, :location => root_path
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def new_vendor
    sign_out current_user
    session[:graph] = nil if session[:graph].present?

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