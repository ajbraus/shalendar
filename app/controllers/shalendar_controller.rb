class ShalendarController < ApplicationController
	def home
		@user = current_user
		@users = User.all
		@followers = current_user.followers
	end

	def manage_follows
		@followers = current_user.followers
		@followed_users = current_user.followed_users
	end
end
