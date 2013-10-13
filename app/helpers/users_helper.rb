module UsersHelper

  def friends_attending(event)
    f = event.guests.select { |a| current_user.is_inmates_or_friends_with?(a) }
    f.count
  end

  def start_time(event)
    if event.starts_at.present?
      event.starts_at.strftime "%l:%M%P, %a %b %e"
    else
      "TBD"
    end
  end

  def date(event)
    if event.starts_at.present?
      event.starts_at.strftime "%A, %b %e"
    else
      "TBD"
    end
  end

  def event_start_time(event)
    if event.starts_at.present?
      event.starts_at.strftime("%l:%M%P")
    else
      "TBD"
    end
  end

  def event_end_time(event)
    if event.ends_at.present?
      event.ends_at.strftime("%l:%M%P")
    else
      "TBD"
    end
  end 

  def next_event_date(event)
    if event.starts_at.present?
      event.starts_at.strftime("%a %b %e")
    else
      "TBD"
    end
  end

  #refactor: method exist in user, profile_picture_url, deprecate this
  def raster_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      fb_picture(user)
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      image_tag user.avatar.url(:raster), class: "img-circle small_profile_picture"
    end
  end 

  def large_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      image_tag "https://graph.facebook.com/#{user.fb_authentication.uid}/picture?type=large", class:"img-circle", width:120
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "large") 
    else
      image_tag user.avatar.url(:original), class:"img-circle", width:120
    end
  end

  def small_profile_picture(user)
    if user.authentications.where(:provider == "Facebook").any?
      facebook_url = "#{user.authentications.find_by_provider("Facebook").pic_url}"
      image_tag(facebook_url, alt: user.name, class: "profile_picture small_pic img-circle" )
    elsif user.authentications.where(:provider == "Twitter").any?
      twitter_picture(user, type: "normal") 
    else
      image_tag user.avatar.url(:raster), class: "img-circle"
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
    image_tag(facebook_url, alt: user.name, class: "profile_picture" )
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
      user.avatar.url(:raster)
    end
  end

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