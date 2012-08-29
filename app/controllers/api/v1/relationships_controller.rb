class Api::V1::RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_follow = User.find_by_id(params[:other_user_id])

    if @mobile_user.following?(@user_to_follow)
      render :status=>400, :json=>{:success=>false, :message=>"You are already following that person!"}
    elsif @user_to_follow.require_confirm_follow?
        Notifier.confirm_follow(@user_to_follow, @mobile_user)
        @mobile_user.follow!(@user_to_follow)
        @relationship = Relationship.last #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
        @relationship.confirmed = false
        if @relationship.save
          render :status=>400, :json=>{:success=>true, :followed_user=>@user_to_follow}
        else
          render :status=>400, :json=>{:success=>false, :message=>"Some server error prevented follow"}
        end
    else
      Notifier.new_follower(@user_to_follow, @mobile_user)
      @mobile_user.follow!(@user_to_follow)
      @relationship = Relationship.last
      @relationship.confirmed = true
      if @relationship.save
        render :status=>400, :json=>{:success=>true, :followed_user=>@user_to_follow}
      else
        render :status=>400, :json=>{:success=>false, :message=>"Some server error prevented follow"}
      end
    end
  end

  def destroy
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_unfollow = User.find_by_id(params[:other_user_id])
    @mobile_user.unfollow!(@user_to_unfollow)
    render :json=>{:success=>true}
  end

  def remove_follower
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_remove = User.find_by_id(params[:other_user_id])
    @user_to_remove.unfollow!(@mobile_user)

    render :json=>{:success=>true}
  end

  def confirm_follower
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_confirm = User.find_by_id(params[:other_user_id])
    @relationship = Relationship.where(':follower_id = :confirm_id AND :followed_id = :mobile_user_id',
                                        confirm_id: @user_to_confirm.id, :mobile_user_id => @mobile_user.id ).last
    @relationship.confirm!
    @relationship.save
    render :json=>{:success=>true, :follower_id=>@user_to_confirm.id}
  end

  def confirm_and_follow
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_confirm = User.find_by_id(params[:other_user_id])
    @relationship = Relationship.where(':follower_id = :confirm_id AND :followed_id = :mobile_user_id',
                                        confirm_id: @user_to_confirm.id, :mobile_user_id => @mobile_user.id ).last
    @relationship.confirm!
    @mobile_user.follow!(@user_to_confirm)
    @relationship.save
    render :json=>{:success=>true, :follower_id=>@user_to_confirm.id, :followed_user=>@user_to_confirm}
  end

end
