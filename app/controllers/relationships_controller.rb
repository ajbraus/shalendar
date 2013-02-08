class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.friend!(@user)
    if @relationship.save
      @user.delay.contact_friend(current_user)
      respond_to do |format|
        format.html { redirect_to :back, notice: "You are now friends with #{@user.name}" }
        format.js
      end
    else
      redirect_to :back, notice: "Couldn't Friend #{@user.name}"
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfriend!(@user)

    respond_to do |format|
      # @plan_counts = []
      # @invite_counts = []
      format.html { redirect_to :back, notice: "You are no longer friends with #{@user.name} on hoos.in" }
      format.js
    end
  end

  def ignore_inmate
    @relationship = Relationship.find(params[:relationship_id])
    @inmate = @relationship.followed
    current_user.ignore_inmate!(@inmate)

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
