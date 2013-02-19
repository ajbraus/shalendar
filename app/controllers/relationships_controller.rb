class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.friend!(@user)
    @user.delay.contact_friend(current_user)
    respond_to do |format|
      format.html { redirect_to :back, notice: "You starred #{@user.name}" }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfriend!(@user)

    respond_to do |format|
      # @plan_counts = []
      # @invite_counts = []
      format.html { redirect_to :back, notice: "You unstarred #{@user.name}" }
      format.js
    end
  end

  def ignore_inmate
    @inmate = User.find_by_id(params[:id])
    current_user.ignore_inmate!(@inmate)

    respond_to do |format|
      format.html { redirect_to user_path(current_user), notice: "Successfully removed #{@inmate.name} from .in-mates" }
      format.js
    end
  end
end
