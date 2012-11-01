module EventsHelper
	def url_encode(text)
		URI.escape("#{text}")
	end
end