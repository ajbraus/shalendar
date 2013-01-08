class DevelopmentMailInterceptor
	def self.delivering_email(message)
		message.subject = "[#{message.to}] - #{message.subject}"
		message.to = "ajbraus@gmail.com"
	end
end
