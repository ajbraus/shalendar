module UsersHelper
  
  def gravatar_for(user, options = { size: 50, })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "profile_picture", title:"#{user.name}")
  end

  def fb_picture(user, options = { type: "large", })
  	fb_id = user.authentications.find_by_provider("Facebook").uid
    type = options[:type]
  	facebook_url = @graph.get_picture(fb_id, { type: type })
  	image_tag(facebook_url, alt: user.name, class: "profile_picture", title:"#{user.name}")
  end

  def twitter_picture(user, options = { type: "large", })
    twitter_username = user.authentications.find_by_provider("Twitter").username
    type = options[:type]
    twitter_url = "https://api.twitter.com/1/users/profile_image?user_id=#{twitter_username}&size=#{type}"
    image_tag(twitter_url, alt: user.name, class: "profile_picture", title:"#{user.name}")
  end

  def big_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      fb_picture(user, type: "large")
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "bigger")
    else
      gravatar_for(user, :size => 120 )
    end
  end

  def medium_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any? 
      fb_picture(user, type: "normal")
    elsif user.authentications.where(:provider == "Twitter").any?
       twitter_picture(user, type: "normal") 
    else
      gravatar_for(user, :size => 100 )
    end
  end

  def small_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      fb_picture(user, type: "small")
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "mini") 
    else
      gravatar_for(user, :size => 45 )
    end
  end

  def raster_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      fb_picture(user, type: "square")
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      gravatar_for(user, :size => 50 )
    end
  end 

end

# add if statement for paperclip/gravatar/FB picture.
# "display profile pic method"