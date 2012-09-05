class Api::V1::ShalendarController < ApplicationController
	before_filter :authenticate_user!
  respond_to :json
  
	def get_user_info

		@user = User.find_by_id(params[:user_id])

    @all_invites = Invite.where("invites.email = :current_user_email", current_user_email: @user.email)
    @invites = []
    @all_invites.each do |i|
      @temp = {
        :eid => i.event_id,
        :i => User.find_by_id(i.inviter_id)
      }
      @invites.push(@temp)
    end

    render :status=>200, :json=>{:user=>{
                                    :user_id=>@user.id,
                                    :first_name=>@user.first_name,
                                    :last_name=>@user.last_name,
                                    :email_hex=> Digest::MD5::hexdigest(@user.email.downcase),
                                    :confirm_f=>@user.require_confirm_follow,
                                    :daily_d=>@user.daily_digest,
                                    :notify_r=>@user.notify_event_reminders,
                                    :notify_n=>@user.notify_noncritical_change,
                                    :post_wall=>@user.post_to_fb_wall,
                                    :followed_users=>@user.followed_users,
                                    :invites=>@invites
                                    }
                                 }
	end

	def followed_users
		@mobile_user = User.find_by_id(params[:id])

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_user.followed_users }
    end
  end

  def followers
  	@mobile_user = User.find_by_id(params[:id])

		respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mobile_user.followers }
    end
  end

end