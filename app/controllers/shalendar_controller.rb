class ShalendarController < ApplicationController
	def home
		@user = current_user
		@users = User.all
	end
end
