module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50, })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "profile_picture")
  end

  def fb_picture(user, options = { type: "large", })
  	fb_id = user.uid
    type = options[:type]
  	facebook_url = @graph.get_picture(fb_id, { type: type })
  	image_tag(facebook_url, alt: user.name, class: "profile_picture")
  end

  def big_profile_picture(user)
    if user.uid != nil 
      fb_picture(user, type: "large")
    else
      gravatar_for(user, :size => 120 )
    end
  end

  def medium_profile_picture(user)
    if user.uid != nil 
      fb_picture(user, type: "normal")
    else
      gravatar_for(user, :size => 100 )
    end
  end

  def small_profile_picture(user)
    if user.uid != nil 
      fb_picture(user, type: "small")
    else
      gravatar_for(user, :size => 45 )
    end
  end

  def raster_profile_picture(user)
    if user.uid != nil 
      fb_picture(user, type: "square")
    else
      gravatar_for(user, :size => 50 )
    end
  end 

end

# add if statement for paperclip/gravatar/FB picture.
# "display profile pic method"