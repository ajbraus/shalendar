class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    redirect_to :back
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to :back 
  end

  def toggle
   #@relationship = Relationship.where('relationships.follower_id = :current_user_id AND relationships.followed_id = :followed_user_id', :current_user_id => current_user.id, :followed_user_id => followed_user.id)
   #@followed_user = fu
   #@relationship = Relationship.find(params[:id])

   @relationship = Relationship.find(params[:relationship_id])
   @relationship.toggle!
   @relationship.save
   flash[:success] = "Toggled User"
   redirect_to :back
  end

end