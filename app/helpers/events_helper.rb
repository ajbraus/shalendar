module EventsHelper
	def event_link(event)
		auto_link(event.link, :html => { :target => "_blank" }) do |text|
	      truncate text, :length => 45
	  end
	end
end