class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    if @user.require_confirm_follow
      Notifier.confirm_follow(@user, current_user).deliver
      #flash[:notice] "Follow Request Sent"
      #Hold relationship to be confirmed somewhere (maybe a confirm_relationships table)
    else
      current_user.follow!(@user)
    end
    redirect_to :back
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to :back 
  end

  def remove
    @follower = Relationship.find(params[:id]).follower
    @follower.unfollow!(current_user)
    redirect_to :back
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

end
