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
      format.html { redirect_to :back, notice: "You friended #{@user.name} and will be alerted when they create or are .in on ideas" }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfriend!(@user)

    respond_to do |format|
      format.html { redirect_to :back, notice: "You unfriended #{@user.name} and will no longer be notified when they create or join .in on ideas" }
      format.js
    end
  end

  def inmate
    @inmate = User.find_by_id(params[:id])
    current_user.inmate!(@inmate)
    @inmate.contact_new_inmate(current_user)
    
    respond_to do |format|
      format.html { redirect_to root_path(id: @inmate.id), notice: "You are now .intros with #{@inmate.name} and will be invited to their ideas" }
      format.js
    end
  end

  def ignore_inmate
    @inmate = User.find_by_id(params[:id])
    current_user.ignore!(@inmate)

    respond_to do |format|
      format.html { redirect_to :back, notice: "You successfully ignored #{@inmate.name} and you will no longer be invited to their ideas" }
      format.js
    end
  end

  def re_inmate
    @intro = User.find_by_id(params[:id])
    current_user.re_inmate!(@intro)

    respond_to do |format|
      format.html { redirect_to root_path(id: @intro.id), notice: "You are now .intros again with #{@intro.name}" }
      format.js
    end
  end

  def inmate_invite
    @invitee_email = params[:email]
    @invitee = User.find_by_id(@invitee_email)
    if @invitee.present?
      @invitee_email = @invitee.email
    end
    
    Notifier.delay.inmate_invite(@invitee_email, current_user)
  end
end
