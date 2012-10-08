class Api::V1::RelationshipsController < ApplicationController
before_filter :authenticate_user!
respond_to :json

include UsersHelper

  def create
    @user = User.find(params[:relationship][:followed_id])

    if @user.require_confirm_follow?  && (@user.following?(current_user) == false)#autoconfirm if already following us
      current_user.follow!(@user)
      @relationship = current_user.relationships.find_by_followed_id(@user.id) #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
      @relationship.confirmed = false
      if @relationship.save
        Notifier.confirm_follow(@user, current_user).deliver
        respond_to do |format|
          format.html { redirect_to :back, notice: "Friend request sent to #{@user.name}" }
          format.js { render template: "relationships/create_no_reload", notice: "Friend request sent to #{@user.name}" }
        end
      else
        redirect_to :back, notice: "Couldn't Friend #{@user.name}"
      end
    else
      Notifier.new_friend(@user, current_user).deliver
      current_user.follow!(@user)
      @relationship = current_user.relationships.find_by_followed_id(@user.id)
      @relationship.confirmed = true
      if @relationship.save
        current_user.add_invitations_from_user(@user)
        unless @user.following?(current_user)
          unless @user.request_following?(current_user) 
            @user.follow!(current_user)
          end
          @reverse_relationship = @user.relationships.find_by_followed_id(current_user.id)
          @reverse_relationship.confirmed = true
          @reverse_relationship.save
          @user.add_invitations_from_user(current_user)
          #also need to add all relevant invitations for both people at this point
        end
        respond_to do |format|
          format.html { redirect_to :back, notice: "Friend request sent to #{@user.name}" }
          @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
          @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
          @plan_counts = []
          @invite_counts = []
          @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
          @date = Time.now.in_time_zone(current_user.time_zone).to_date
          format.js
        end
      else
        redirect_to :back, notice: "Couldn't Friend #{@user.name}"
      end
    end
  end

  def create
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_follow = User.find_by_id(params[:other_user_id])

    if @mobile_user.following?(@user_to_follow)
      render :status=>200, :json=>{ :followed_user=>@user_to_follow}
      return
    elsif @user_to_follow.require_confirm_follow? && (@user_to_follow.following?(current_user) == false)
        @mobile_user.follow!(@user_to_follow)
        @relationship = @mobile_user.find_by_followed_id(@user_to_follow.id)
        @relationship.confirmed = false
        if @relationship.save
          Notifier.confirm_follow(@user_to_follow, @mobile_user).deliver
          render :status=>200, :json=>{:success=>true, :pfu=>@user_to_follow}
          return
        else
          render :status=>400, :json=>{:success=>false, :message=>"Some server error prevented follow"}
          return
        end
    else
      Notifier.new_friend(@user_to_follow, @mobile_user).deliver
      @mobile_user.follow!(@user_to_follow)
      @relationship = @mobile_user.relationships.find_by_followed_id(@user_to_follower.id)
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
          #also need to add all relevant invitations for both people at this point
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
    @user_to_unfollow = User.find_by_id(params[:other_user_id])
    if @mobile_user.following?(@user_to_unfollow)
      @mobile_user.unfollow!(@user_to_unfollow)
      @mobile_user.delete_invitations_from_user(@user_to_unfolow)
      @user_to_unfollow.unfollow!(@mobile_user)
      @user_to_unfollow.delete_invitations_from_user(@mobile_user)
    end
    render :json=>{:unfollowed_id=>@user_to_unfollow.id}
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
