class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    #@relationship = current_user.relationships.build(params[:relationship])
    if @user.require_confirm_follow?
      Notifier.confirm_follow(@user, current_user)
      #@relationship.confirmed = false
      current_user.follow!(@user)
      @relationship = Relationship.last
      @relationship.confirmed = false
      if @relationship.save
        redirect_to :back, notice: "View request sent to #{@user.name}"
      else
        redirect_to :back, notice: "Couldn't View #{@user.name}'s Calenshare"
      end
    else
      #@relationship.confirmed = true
      Notifier.new_follower(@user, current_user)
      current_user.follow!(@user)
      @relationship = Relationship.last
      @relationship.confirmed = true
      if @relationship.save
        redirect_to :back, notice: "Now you're viewing #{@user.name}'s Calenshare"
      else
        redirect_to :back, notice: "Couldn't View #{@user.name}'s Calenshare"
      end
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to :back, notice: "#{@user.name} can no longer view your Calenshare"
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
