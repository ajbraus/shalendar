class Api::V2::RelationshipsController < ApplicationController
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
    end
    @mobile_user.friend!(@user_to_follow)

    render :status=>200, :json=>{:success=>true, :fu=>@user_to_follow}
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

    @mobile_user.unfriend!(@other_user_to_unfollow)

    render :json=>{:unfollowed_id=>@other_user_to_unfollow.id}
  end

  def add_star
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_star = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_star.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @mobile_user.friend!(@other_user_to_star)

    render :json=>{:starred_id=>@other_user_to_star.id}
  end

  def remove_star

    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_star = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_star.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @mobile_user.unfriend!(@other_user_to_star)

    render :json=>{:unstarred_id=>@other_user_to_star.id}

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

  def search_for_friends
    @found_users = User.search(params[:search_string])

    render json: @found_users

  end

  def search_for_fb_friends

    @graph = Koala::Facebook::API.new(params[:access_token]) 
    @found_users = current_user.fb_friends(@graph)[0]

    render json: @found_users.reject{|fu|current_user.following?(fu)}

  end

  def get_friends

    render json: current_user.inmates | current_user.friends

  end


end
