class Api::V1::RelationshipsController < ApplicationController
before_filter :authenticate_user!
respond_to :json

include UsersHelper

  def create
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_follow = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @user_to_follow.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @mobile_user.following?(@user_to_follow)
      render :status=>200, :json=>{ :followed_user=>@user_to_follow}
      return
    elsif @user_to_follow.require_confirm_follow? && (@user_to_follow.following?(@mobile_user) == false)
        @mobile_user.follow!(@user_to_follow)
        @relationship = @mobile_user.find_by_followed_id(@user_to_follow.id)
        @relationship.confirmed = false
        if @relationship.save
          @user_to_follow.delay.contact_confirm(@mobile_user)
          render :status=>200, :json=>{:success=>true, :pfu=>@user_to_follow}
          return
        else
          render :status=>400, :json=>{:success=>false, :message=>"Some server error prevented follow"}
          return
        end
    else
      @user_to_follow.delay.contact_friend(@mobile_user)
      @mobile_user.follow!(@user_to_follow)
      @relationship = @mobile_user.relationships.find_by_followed_id(@user_to_follow.id)
      @relationship.confirmed = true
      if @relationship.save
        @mobile_user.add_invitations_from_user(@user_to_follow)
        unless @user_to_follow.following?(@mobile_user)
          unless @user_to_follow.request_following?(@mobile_user) 
            @user_to_follow.follow!(@mobile_user)
          end
          @reverse_relationship = @user_to_follow.relationships.find_by_followed_id(@mobile_user.id)
          @reverse_relationship.confirmed = true
          @reverse_relationship.save
          @user_to_follow.add_invitations_from_user(@mobile_user)
        end
        render :status=>200, :json=>{:success=>true, :fu=>@user_to_follow}
        return
      else
        render :status=>400, :json=>{:success=>false, :message=>"Some server error prevented follow"}
        return
      end
    end
  end

  def destroy
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_unfollow = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_unfollow.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    if @mobile_user.following?(@other_user_to_unfollow)
      @mobile_user.unfollow!(@other_user_to_unfollow)
      @mobile_user.delete_invitations_from_user(@other_user_to_unfolow)
      @other_user_to_unfollow.unfollow!(@mobile_user)
      @other_user_to_unfollow.delete_invitations_from_user(@mobile_user)
    end
    render :json=>{:unfollowed_id=>@other_user_to_unfollow.id}
  end

  def remove_follower
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_remove = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_remove.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @other_user_to_remove.unfollow!(@mobile_user)


    render :json=>{:success=>true}
  end

  def confirm_follower
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_confirm = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_confirm.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end
    @relationship = Relationship.where(':follower_id = :confirm_id AND :followed_id = :mobile_user_id',
                                         confirm_id: @other_user_to_confirm.id, :mobile_user_id => @mobile_user.id ).last
    unless @relationship.nil?
      @relationship.confirm!
      @relationship.save
    end
    render :json=>{:success=>true, :follower_id=>@other_user_to_confirm.id}
  end

  def confirm_and_follow
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_confirm = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_confirm.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end
    @relationship = Relationship.where(':follower_id = :confirm_id AND :followed_id = :mobile_user_id',
                                        confirm_id: @other_user_to_confirm.id, :mobile_user_id => @mobile_user.id ).last
    unless @relationship.nil?
      @relationship.confirm!
      @mobile_user.follow!(@other_user_to_confirm)
      @relationship.save
    end
    render :json=>{:success=>true, :follower_id=>@other_user_to_confirm.id, :followed_user=>@other_user_to_confirm}
  end

end
