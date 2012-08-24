class Api::V1::ShalendarController < ApplicationController
	before_filter :authenticate_user!

	def followed_users
		@mobile_user = User.find_by_id(3)
		@followed_users = @mobile_user.followed_users

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @followed_users }
    end
  end
end