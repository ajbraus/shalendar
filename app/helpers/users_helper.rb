module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50, })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.fullname, class: "profile_picture")
  end

  def fb_picture(user, options = { size: 50, type: large, })
  	fb_id = current_user.uid
  	size = options[:size]
  	type = options[:type]
  	facebook_url = @graph.get_picture(fb_id)
  	image_tag(facebook_url, alt: user.fullname, class: "profile_picture")
  end
end

# add if statement for paperclip/gravatar/FB picture.
# "display profile pic method"