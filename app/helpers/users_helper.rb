module UsersHelper

  # def default_url
  #   return "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png"
  # end

  def friends_attending(event)
    f = event.guests.select { |a| current_user.following?(a) }
    f.count
  end

  def start_time(event)
    event.starts_at.strftime "%l:%M%P, %A %B %e"
  end

  def date(event)
    event.starts_at.strftime "%A, %b %e"
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

  def raster_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      fb_picture(user)
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      # if user.avatar.url.nil?
      #   image_tag "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png",
      #    class: "profile_picture"
      # else
      #image_tag user.avatar.url, class: "profile_picture"
    end
  end 

  # def gravatar_for(user, options = { size: 50, })
  #   gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
  #   size = options[:size]
  #   gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  #   image_tag gravatar_url, alt: user.name, class: "profile_picture"
  # end

  def fb_picture(user)
  	facebook_url = "#{user.authentications.find_by_provider("Facebook").pic_url}"
  	#image_tag(facebook_url, alt: user.name, class: "profile_picture" )
  end

  def twitter_picture(user, options = { type: "large", })
    twitter_username = user.authentications.find_by_provider("Twitter").username
    type = options[:type]
    twitter_url = "https://api.twitter.com/1/users/profile_image?user_id=#{twitter_username}&size=#{type}"
    image_tag(twitter_url, alt: user.name, class: "profile_picture" )
  end

# Invite raster

  def invite_raster_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      "#{user.authentications.find_by_provider("Facebook").pic_url}"
    elsif user.authentications.where(:provider == "Twitter").any?
      invite_twitter_picture(user, type: "normal") 
    else
      # if user.avatar.url.nil?
      #   image_tag "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png",
      #    class: "profile_picture"
      # else
      user.avatar.url
      #invite_gravatar_for(user, :size => 50 )
    end
  end

  # def invite_gravatar_for(user, options = { size: 50, })
  #   gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
  #   size = options[:size]
  #   "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  # end

  def invite_twitter_picture(user, options = { type: "large", })
    twitter_username = user.authentications.find_by_provider("Twitter").username
    type = options[:type]
    "https://api.twitter.com/1/users/profile_image?user_id=#{twitter_username}&size=#{type}"
  end

  def output_once(name, &block)
    @output_once_blocks ||= []
    unless @output_once_blocks.include?(name)
        @output_once_blocks << name
        concat(capture(block), block.binding)
    end
  end

end

# add if statement for paperclip/gravatar/FB picture.
# "display profile pic method"