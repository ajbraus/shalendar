module EventsHelper
	def url_encode(text)
		URI.escape("#{text}")
	end

	def youtube_embed(youtube_url)
  	if youtube_url[/youtu\.be\/([^\?]*)/]
    	youtube_id = $1
  	else
    	# Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    	youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
    	youtube_id = $5
  	end

 		%Q{<iframe title="YouTube video player" width="100%" height="400" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
 	end

  def promo_image_url(event)
    if event.promo_url  && event.promo_url != ''
      return event.promo_url
    elsif !event.promo_img_file_size.nil?
      return event.promo_img.url(:medium)
    end
  end

  def public_count
    @current_city.events.select { |e| !e.has_parent? && e.is_public? && current_user.out?(e) }.count
  end
  
# END OF CLASS
end