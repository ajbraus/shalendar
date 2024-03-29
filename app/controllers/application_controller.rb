class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_city, :except => [:city_names]
  before_filter :set_graph
  after_filter :store_location

  around_filter :user_time_zone, :if => :current_user, :except => [:pick_city, :city_names, :update]
  # before_filter :instantiateUser

  # def instantiateUser
  #   if user_signed_in?
  #     @user = current_user
  #   else
  #     @user = User.new
  #   end
  # end
  private 

  def user_time_zone(&block)
    Time.use_zone(current_user.city.timezone, &block)
  end

  def store_location
    session[:previous_urls] ||= []
    # store unique urls only
    session[:previous_urls].prepend request.fullpath if session[:previous_urls].first != request.fullpath && (request.fullpath.starts_with?('/ideas') || request.fullpath.starts_with?('/users'))
    # For Rails < 3.2
    # session[:previous_urls].unshift request.fullpath if session[:previous_urls].first != request.fullpath 
    session[:previous_urls].pop if session[:previous_urls].count > 3
  end

  def after_sign_in_path_for(resource)
    if session[:previous_urls].present? 
      @url = session[:previous_urls].reverse.first

      if @url.present? && Rails.env.production?
        "http://www.hoos.in" + @url
      # elsif @url.present?
      #   "http://www.hoos.dev" + @url
      else
        root_path
      end
    else
      root_path
    end
  end

  def set_city
    @user = User.find_by_slug(params[:id])
    if @user.present?
      @current_city = @user.city
    elsif user_signed_in?
      @current_city = current_user.city
      if @current_city.blank?
        redirect_to pick_city_path
      end
    else
      @current_city = City.find_by_name("Madison, Wisconsin")
    end
  end

  def set_graph
    if user_signed_in?
      if current_user.authentications.find_by_provider("Facebook").present?
        @graph = session[:graph] 
      else 
        session[:graph] = nil
      end
    else
      @graph = nil
    end
  end

  def check_venue_card
    if user_signed_in?
      if !current_user.has_valid_credit_card? && current_user.sign_in_count != 1
        flash[:notice] = "Our records show you must update your credit card data"
      end
    end
  end
end
