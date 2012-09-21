class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])

    if @user.require_confirm_follow?  && (@user.following?(current_user) == false)#autoconfirm if already following us
      current_user.follow!(@user)
      @relationship = current_user.relationships.find_by_followed_id(@user.id) #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
      @relationship.confirmed = false
      Notifier.confirm_follow(@user, current_user).deliver
      if @relationship.save
        respond_to do |format|
          format.html { redirect_to :back, notice: "Friend request sent to #{@user.name}" }
          format.js { render template: "create_no_reload", notice: "Friend request sent to #{@user.name}" }
        end
      else
        redirect_to :back, notice: "Couldn't Friend #{@user.name}"
      end
    else
      Notifier.new_follower(@user, current_user).deliver
      current_user.follow!(@user)
      @relationship = current_user.relationships.find_by_followed_id(@user.id)
      @relationship.confirmed = true
      if @relationship.save
        respond_to do |format|
          @user.follow!(current_user)
          @reverse_relationship = @user.relationships.find_by_followed_id(current_user.id)
          @reverse_relationship.confirmed = true
          @reverse_relationship.save
          format.html { redirect_to :back, notice: "Friend request sent to #{@user.name}" }
          @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
          @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone).to_s)
          @date = Time.now.in_time_zone(current_user.time_zone).to_date
          format.js
        end
      else
        redirect_to :back, notice: "Couldn't Friend #{@user.name}"
      end
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    @user.unfollow!(current_user)
    respond_to do |format|
      @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
      @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone).to_s)
      @date = Time.now.in_time_zone(current_user.time_zone)
      format.html { redirect_to :back, notice: "You are no longer friends with #{@follower.name} on hoos.in" }
      format.js
    end
  end

  def remove
    @relationship = Relationship.find(params[:relationship_id])
    @follower = @relationship.follower
    @follower.unfollow!(current_user)
    current_user.unfollow!(@follower)
    redirect_to :back, notice: "You are no longer friends with #{@follower.name} on hoos.in"
  end

  def toggle
   @relationship = Relationship.find(params[:relationship_id])
   @relationship.toggle!
   @relationship.save
   respond_to do |format|
    format.html { redirect_to :back }
     @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone).to_s)
     @date = Time.now.in_time_zone(current_user.time_zone)     
     @forecastoverview = current_user.forecastoverview
     @graph = session[:graph]
     format.js
   end
  end

  # def confirm
  #   @relationship = Relationship.find(params[:relationship_id])
  #   @relationship.confirm!
  #   @relationship.save
  #   redirect_to :back, notice: "#{@relationship.follower.name} can now view your ideas"
  # end

  def confirm_and_follow
    @relationship = Relationship.find(params[:relationship_id])
    @relationship.confirm!
    @relationship.save
    current_user.follow!(@relationship.follower)
    @reverse_relationship = current_user.relationships.find_by_followed_id(@relationship.follower.id)
    @reverse_relationship.confirm!
    if @reverse_relationship.save 
      respond_to do |format|
        @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
        @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone).to_s)
        @date = Time.now.in_time_zone(current_user.time_zone)
        format.html { redirect_to :back, notice: "You are no longer friends with #{@follower.name} on hoos.in" }
        format.js
      end
    else
      redirect_to :back, notice: "Couldn't Friend #{@user.name}"
    end
  end
end
