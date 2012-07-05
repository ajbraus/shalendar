class ShalendarController < ApplicationController
	def home
		@user = current_user
		@users = User.all
		@events = Event.all
	end
end
