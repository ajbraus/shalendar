class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.friend!(@user)
    @new_friendship = Relationship.where('followed_id = ? AND follower_id = ? AND status = ?', @user.id, current_user.id, 2).first
    unless @new_friendship.updated_at > Time.zone.now - 1.hour
      @user.delay.contact_friend(current_user)
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: "You starred #{@user.name}" }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfriend!(@user)

    respond_to do |format|
      format.html { redirect_to :back, notice: "You unstarred #{@user.name}" }
      format.js
    end
  end

  def ignore_inmate
    @inmate = User.find_by_id(params[:id])
    current_user.ignore_inmate!(@inmate)

    respond_to do |format|
      format.html { redirect_to :back, notice: "Successfully removed #{@inmate.name} from friends" }
      format.js
    end
  end

  def re_inmate
    @inmate = User.find_by_id(params[:id])
    current_user.re_inmate!(@inmate)

    respond_to do |format|
      format.html { redirect_to user_path(@inmate), notice: "You are now friends again with #{@inmate.name}" }
      format.js
    end
  end

  def inmate_invite
    @invitee_email = params[:email]
    @invitee = User.find_by_id(@invitee_email)
    if @invitee.present?
      @invitee_email = @invitee.email
    end
    
    Notifier.inmate_invite(@invitee_email, current_user)
  end

  def inmate
    @inmate = User.find_by_id(params[:id])
    current_user.inmate!(@inmate)
    @inmate.contact_new_inmate(current_user)
    
    respond_to do |format|
      format.html { redirect_to user_path(@inmate), notice: "You are now friends with #{@inmate.name}" }
      format.js
    end
  end
end
