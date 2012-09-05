class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
     @user = User.find(params[:relationship][:followed_id])

    if @user.require_confirm_follow?
      Notifier.confirm_follow(@user, current_user)
      current_user.follow!(@user)
      @relationship = Relationship.last #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
      @relationship.confirmed = false
      if @relationship.save
        respond_to do |format|
         @relationships = current_user.relationships.where('relationships.confirmed = true')
         @forecastevents = current_user.forecast((Date.today).to_s)
         @date = Date.today
         format.html { redirect_to :back, notice: "View request sent to #{@user.name}" }
         format.js
        end
      else
        redirect_to :back, notice: "Couldn't View #{@user.name}'s ideas"
      end
    else
      Notifier.new_follower(@user, current_user)
      current_user.follow!(@user)
      @relationship = Relationship.last
      @relationship.confirmed = true
      if @relationship.save
        respond_to do |format|
         @relationships = current_user.relationships.where('relationships.confirmed = true')
         @forecastevents = current_user.forecast((Date.today).to_s)
         @date = Date.today
         format.html { redirect_to :back, notice: "View request sent to #{@user.name}" }
         format.js
        end
      else
        redirect_to :back, notice: "Couldn't View #{@user.name}'s ideas"
      end
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
     @relationships = current_user.relationships.where('relationships.confirmed = true')
     @forecastevents = current_user.forecast((Date.today).to_s)
     @date = Date.today
     format.html { redirect_to :back, notice: "#{@user.name} can no longer view your ideas" }
     format.js
    end
  end

  def remove
    @relationship = Relationship.find(params[:relationship_id])
    @follower = @relationship.follower
    @follower.unfollow!(current_user)
    redirect_to :back, 
                notice: "#{@follower.name} can no longer view your ideas"
  end

  def toggle
   @relationship = Relationship.find(params[:relationship_id])
   @relationship.toggle!
   @relationship.save
   respond_to do |format|
     @forecastevents = current_user.forecast((Date.today).to_s)
     @date = Date.today     
     format.html { redirect_to :back }
     format.js
   end
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
