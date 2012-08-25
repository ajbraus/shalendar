# app/controllers/api/v1/token_authentications_controller.rb
# module Api
#   module V1
#     class TokenAuthenticationsController < ApplicationController
#     before_filter :authenticate_user!
     
#       def create
#         @user = current_user
#         @user.reset_authentication_token!
#         redirect_to edit_user_registration_path(@user)
#       end
     
#       def destroy
#         @user = current_user
#         @user.authentication_token = nil
#         @user.save
#         redirect_to edit_user_registration_path(@user)
#       end
#     end
#   end
# end

class Api::V1::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  def create
    email = params[:email]
    password = params[:password]
    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end
 
    if email.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user email and password."}
       return
    end

    @user=User.find_by_email(email.downcase)

    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid email or passoword."}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!
    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
    else
      # THIS IS FOR SENDING FOLLOWED/FOLLOWER INFO FROM LOGIN
      @followed_users = []
      @user.followed_users.each do |fu|
        r = @user.relationships.find_by_followed_id(fu.id)
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
      #FOR FOLLOWERS, DON"T KNOW IF WE CARE
      # @followers = []
      # @user.followers.each do |f|
      #   r = Relationship.where("follower_id = :followerid AND @followed_id = :followedid", 
      #                           followerid: f.id, followedid: @user.id).last #should just be a find call
      #   @temp = {
      #     first_name: f.first_name,
      #     last_name: f.last_name,
      #     id: f.id,
      #     email_hex: Digest::MD5::hexdigest(f.email.downcase),
      #     confirmed: r.confirmed,
      #     toggled: r.toggled
      #   }
      #   @followers.push(@temp)
      # end
      @all_invites = Invite.where("invites.email = :current_user_email", current_user_email: @user.email)
      @invites = []
      @all_invites.each do |i|
        @temp = {
          :eid => i.event_id,
          :iid => i.inviter_id
        }
        @invites.push(@temp)
      end

      render :status=>200, :json=>{:token=>@user.authentication_token, 
                                    :user=>{
                                      :user_id=>@user.id,
                                      :first_name=>@user.first_name,
                                      :last_name=>@user.last_name,
                                      :confirm_f=>@user.require_confirm_follow,
                                      :daily_d=>@user.daily_digest,
                                      :notify_r=>@user.notify_event_reminders,
                                      :notify_n=>@user.notify_noncritical_change,
                                      :post_wall=>@user.post_to_fb_wall,
                                      :followed_users=>@followed_users,#may put these in separate calls for speed of login
                                      #:followers=>@followers,
                                      :invites=>@invites
                                    }
                                   }
    end
  end

  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

end
