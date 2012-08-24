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
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to :back, 
                notice: "#{@user.name} can no longer view your ideas"
  end



  def remove
    @relationship = Relationship.find(params[:relationship_id])
    @follower = @relationship.follower
    @follower.unfollow!(current_user)
    redirect_to :back, 
                notice: "#{@follower.name} can no longer view your ideas"
  end

  def toggle
   #@relationship = Relationship.where('relationships.follower_id = :current_user_id AND relationships.followed_id = :followed_user_id', :current_user_id => current_user.id, :followed_user_id => followed_user.id)
   #@followed_user = fu
   #@relationship = Relationship.find(params[:id])

   @relationship = Relationship.find(params[:relationship_id])
   @relationship.toggle!
   @relationship.save
   redirect_to :back

  end

  def confirm
    @relationship = Relationship.find(params[:relationship_id])
    @relationship.confirm!
    @relationship.save
    redirect_to :back, notice: "#{@relationship.follower.name} can now view your ideas"
  end

  def confirm_and_follow
    @relationship = Relationship.find(params[:relationship_id])
    @relationship.confirm!
    @relationship.save

    #@other_user = @relationship.follower
    
    current_user.follow!(@relationship.follower)
    @new_relationship = Relationship.last
    if(@relationship.follower.require_confirm_follow == true)
      @new_relationship.confirmed = false
    else
      @new_relationship.confirmed = true
    end
    if @new_relationship.save 
      redirect_to :back, notice: "#{@relationship.follower.name} can now view your ideas and request sent to view back"
    else
      redirect_to :back, notice: "Couldn't View #{@user.name}'s ideas"
    end
  end
end
