module UsersHelper
  
  def event_blerb(event)
    if event.title.size >=26
      event.title.slice(0..24) + "..."
    else
      event.title
    end
  end

  def friends_attending(event)
    f = event.guests.select { |a| current_user.following?(a) }
    f.count
  end

  def start_time(event)
    event.starts_at.strftime "%l:%M%P, %A %B %e"
  end

  def date(event)
    event.starts_at.strftime "%A, %B %e"
  end

  def event_start_time(event)
    event.starts_at.strftime("%l:%M%P")
  end

  def event_end_time(event)
    event.ends_at.strftime("%l:%M%P")
  end 

  def next_event_date(event)
    event.starts_at.strftime("%a %b %e")
  end

  def gravatar_for(user, options = { size: 50, })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "profile_picture" )
  end

  def fb_picture(user, options = { type: "large", })
  	fb_id = user.authentications.find_by_provider("Facebook").uid
    type = options[:type]
  	facebook_url = @graph.get_picture(fb_id, { type: type })
  	image_tag(facebook_url, alt: user.name, class: "profile_picture" )
  end

  def twitter_picture(user, options = { type: "large", })
    twitter_username = user.authentications.find_by_provider("Twitter").username
    type = options[:type]
    twitter_url = "https://api.twitter.com/1/users/profile_image?user_id=#{twitter_username}&size=#{type}"
    image_tag(twitter_url, alt: user.name, class: "profile_picture" )
  end

  def medium_profile_picture(user)
    if user.avatar.present?
      image_tag user.avatar.url(:medium), style:"border-radius: 7px;"
    elsif user.authentications.where(:provider == "Facebook").any? 
      fb_picture(user, type: "normal")
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      gravatar_for(user, :size => 100 )
    end
  end

  def raster_profile_picture(user)
    if user.avatar.present?
      image_tag user.avatar.url(:raster), style:"border-radius: 7px;"
    elsif user.authentications.where(:provider == "Facebook").any?
      fb_picture(user, type: "square")
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      gravatar_for(user, :size => 50 )
    end
  end 


# Invite raster

  def invite_raster_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      invite_fb_picture(user, type: "square")
    elsif user.authentications.where(:provider == "Twitter").any?
      invite_twitter_picture(user, type: "normal") 
    else
      invite_gravatar_for(user, :size => 50 )
    end
  end

  def invite_gravatar_for(user, options = { size: 50, })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def invite_fb_picture(user, options = { type: "large", })
    fb_id = user.authentications.find_by_provider("Facebook").uid
    type = options[:type]
    @graph.get_picture(fb_id, { type: type })
  end

  def invite_twitter_picture(user, options = { type: "large", })
    twitter_username = user.authentications.find_by_provider("Twitter").username
    type = options[:type]
    "https://api.twitter.com/1/users/profile_image?user_id=#{twitter_username}&size=#{type}"
  end
end

# add if statement for paperclip/gravatar/FB picture.
# "display profile pic method"