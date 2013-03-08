class Api::V2::ShalendarController < ApplicationController
	before_filter :authenticate_user!
  respond_to :json
  
	def get_profile

		@user = User.find_by_id(params[:user_id])
    if @user.nil?
      render :status=>400, :json=>{
        :error => "user was not found."
      }
    end


    render :status=>200, :json=>{:user=>{
                                    :user_id=>@user.id,
                                    :first_name=>@user.first_name,
                                    :last_name=>@user.last_name,
                                    :email_hex=> Digest::MD5::hexdigest(@user.email.downcase),
                                    :confirm_f=>@user.require_confirm_follow,
                                    :daily_d=>@user.allow_contact,
                                    :notify_r=>@user.notify_event_reminders,
                                    :post_wall=>@user.post_to_fb_wall,
                                    :followed_users=>@user.followed_users
                                    }
                                 }
	end

	def followed_users
		@mobile_user = User.find_by_id(params[:id])

    if @mobile_user.nil?
      render :status=>400, :json=>{
        :error => "user was not found."
      }
    end

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_user.followed_users }
    end
  end

  def followers
  	@mobile_user = User.find_by_id(params[:id])
    if @mobile_user.nil?
      render :status=>400, :json=>{
        :error => "user was not found."
      }
    end
		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_user.followers }
    end
  end

end