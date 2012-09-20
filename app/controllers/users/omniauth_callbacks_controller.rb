class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    oauthorize "Facebook"
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
private

  def oauthorize(kind)
    @user = find_for_oauth(kind, env["omniauth.auth"], current_user)
    if @user.present?
      #put a flash into the session
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind

      #get shortlived access token, exchange it for a long lived one, save it in the session.
      @short_token = env["omniauth.auth"].credentials.token
      @long_token = HTTParty.get("https://graph.facebook.com/oauth/access_token?client_id=327936950625049&client_secret=4d3de0cbf2ce211f66733f377b5e3816&grant_type=fb_exchange_token&fb_exchange_token=#{@short_token}")
      #get back "access_token=AAAEqQcVzYxkBAFPwIFPN7sUsdNZA5gZBIzZCRVbufmkJMlK2OOlITw6cmeZAFgRkrnvVfrCAwG9zZCKDfQRHe163UZAuPhsHUZD&expires=5181597"
      #save it in the session
      session[:access_token] = @long_token.split('=')[1].split('&')[0]
      session[:graph] = Koala::Facebook::API.new(session[:access_token]) 
      @uid = env["omniauth.auth"].uid
      @user.authentications.find_by_uid(@uid).token = session[:access_token]

      @city = env["omniauth.auth"].info.location
        unless City.find_by_name(@city)
          c = City.new(name: @city)
          c.save
        end

      # session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
      sign_in_and_redirect @user, :event => :authentication
    else
      redirect_to :back, notice: 'There was an error with Facebook. Check your Facebook account status.'
    end   
  end

  def find_for_oauth(provider, access_token, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, {}
    case provider
    when "Facebook"
      uid = access_token.uid
      email = access_token.info.email
      token = access_token.credentials.token
      @graph = Koala::Facebook::API.new
      pic_url = @graph.get_picture(uid)
      auth_attr = { :uid => uid, :token => token, :secret => nil, :pic_url => pic_url }
    else
      raise 'Provider #{provider} not handled'
    end
    if resource.nil?
      if email
        user = find_for_oauth_by_email(email, access_token, resource)
      else uid
        user = find_for_oauth_by_uid(uid, access_token, resource)
      end
    else
      user = resource
    end
    
    auth = user.authentications.find_by_provider(provider)
    if auth.nil? && Authentication.find_by_uid(uid).nil?     
      auth = user.authentications.build(:provider => provider)
      user.authentications << auth
    end
    if auth.present?
      auth.update_attributes auth_attr
    end

    if auth.nil?
      user = nil
    end
    return user
  end

  def find_for_oauth_by_uid(uid, access_token, resource=nil)
    user = nil
    if auth = Authentication.find_by_uid(uid.to_s)
      user = auth.user
    end
    return user
  end

  def find_for_oauth_by_email(email, access_token, resource=nil)
    if user = User.find_by_email(email)
      email = access_token.info.email
      name = access_token.info.name
      location = access_token.info.location
      time_zone = "Central Time (US & Canada)" #timezone_for_utc_offset(access_token.extra.raw_info.timezone)

      user_attr = { email: email, name: name, city: location, time_zone: time_zone }
      user.update_attributes user_attr
      
      return user

    else
      email = access_token.info.email
      name = access_token.info.name
      city = access_token.info.location
      time_zone = "Central Time (US & Canada)"  # timezone_for_utc_offset(access_token.extra.raw_info.timezone)

      user = User.new(:email => email, 
                :name => name,
                :city => city,
                :time_zone => time_zone,
                :terms => true,
                :remember_me => true,
                :password => Devise.friendly_token[0,20]
              )
      user.save
      EmailInvite.where("email_invites.email = :new_user_email", new_user_email: user.email).each do |ei|
        @inviter_id = ei.inviter_id
        @invited_user_id = user.id
        @event = ei.event
        if @inviter = User.find_by_id(@inviter_id)
          @inviter.invite!(@event, user)
        end
        ei.destroy
      end
      return user
    end
  end
  
  def timezone_for_utc_offset(utc_offset)
    identifier = {
      -11  => 'Samoa',#International Date Line West, Midway Island
      -10  => 'Hawaii',
      -9   => 'Alaska',
      -8   => 'Pacific Time (US & Canada)',#Tijuana
      -7   => 'Mountain Time (US & Canada)',#Arizona, Chihuahua, Mazatlan
      -6   => 'Central Time (US & Canada)',#Central America, Guadalajara, Mexico City, Monterrey, Saskatchewan
      -5   => 'Eastern Time (US & Canada)',#Bogota, Indiana (East), Lima, Quito
      -4.5 => 'Caracas',
      -4   => 'Atlantic Time (Canada)',#Georgetown, La Paz, Santiago
      -3.5 => 'Newfoundland',
      -3   => 'Buenos Aires',#Brasilia, Greenland
      -2   => 'Mid-Atlantic',
      -1   => 'Cape Verde Is.',#Azores
      0    => 'London',#Casablanca, Dublin, Edinburgh, Lisbon, Monrovia, UTC
      1    => 'Paris',#Amsterdam, Belgrade, Berlin, Bern, Bratislava, Brussels, Budapest, Copenhagen, Ljubljana, Madrid, Prague, Rome, Sarajevo, Skopje, Stockholm, Vienna, Warsaw, West Central Africa, Zagreb
      2    => 'Cairo',#Athens, Bucharest, Harare, Helsinki, Istanbul, Jerusalem, Kyiv, Minsk, Pretoria, Riga, Sofia, Tallinn, Vilnius
      3    => 'Moscow',#Baghdad, Kuwait, Nairobi, Riyadh, St. Petersburg, Volgograd
      3.5  => 'Tehran',
      4    => 'Baku',#Abu Dhabi, Muscat, Tbilisi, Yerevan
      4.5  => 'Kabul',
      5    => 'Karachi',#Ekaterinburg, Islamabad, Tashkent
      5.5  => 'Mumbai',#Chennai, Kolkata, New Delhi, Sri Jayawardenepura
      5.75 => 'Kathmandu',
      6    => 'Dhaka',#Almaty, Astana, Novosibirsk
      6.5  => 'Rangoon',
      7    => 'Jakarta',#Bangkok, Hanoi, Krasnoyarsk
      8    => 'Hong Kong',#Beijing, Chongqing, Irkutsk, Kuala Lumpur, Perth, Singapore, Taipei, Ulaan Bataar, Urumqi
      9    => 'Tokyo',#Osaka, Sapporo, Seoul, Yakutsk
      9.5  => 'Adelaide',#Darwin
      10   => 'Sydney',#Brisbane, Canberra, Guam, Hobart, Melbourne, Port Moresby, Vladivostok
      11   => 'Solomon Is.',#Kamchatka, Magadan, New Caledonia
      12   => 'Auckland',#Fiji, Marshall Is., Wellington
      13   => "Nuku'alofa",
    }
    return identifier[utc_offset-1]#put in -1 bc looks like FB is off by 1
end
  # def find_for_oauth_by_name(name, resource=nil)
  #   if user = User.find_by_name(name)
  #     user
  #   else
  #     user = User.new(:name => name, :password => Devise.friendly_token[0,20], :email => "#{UUIDTools::UUID.random_create}@host")
  #     user.save false
  #   end
  #   return user
  # end
end
