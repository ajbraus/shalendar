class Api::V1::ShalendarController < ApplicationController
	before_filter :authenticate_user!

	def followed_users
		@mobile_user = User.find_by_id(params[:id])
		@followed_users = []
		@mobile_user.followed_users.each do |fu|
			r = @mobile_user.relationships.find_by_followed_id(fu.id)
			@temp = {
				first_name: fu.first_name,
				last_name: fu.last_name,
				id: fu.id,
				email_hex: Digest::MD5::hexdigest(fu.email.downcase),
				confirmed: r.confirmed,
				toggled: r.toggled
			}
			@followed_users.push(@temp)
		end
		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @followed_users }
    end
  end

  def followers
  	@mobile_user = User.find_by_id(params[:id])
		@followers = []
		@mobile_user.followers.each do |f|
			r = @mobile_user.relationships.find_by_follower_id(f.id)
			@temp = {
				first_name: f.first_name,
				last_name: f.last_name,
				id: f.id,
				email_hex: Digest::MD5::hexdigest(f.email.downcase),
				confirmed: r.confirmed,
				toggled: r.toggled
			}
			@followers.push(@temp)
		end

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @followers }
    end


  end

end