class RelationshipsController < ApplicationController
before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    #IF VENDOR
    if current_user.vendor?
      redirect_to :back, notice: "Couldn't Friend #{@user.name}"
    #IF ALREADY FOLLOWING OR REQUESTED TO FOLLOW
    elsif current_user.following?(@user) || current_user.request_following?(@user)
      redirect_to :back, notice: "You are already friends"
    #IF REQUIRES CONFIRM FOLLOW
    elsif @user.require_confirm_follow?  && @user.following?(current_user) == false #autoconfirm if already following us
      current_user.follow!(@user)
      @relationship = current_user.relationships.find_by_followed_id(@user.id) #should really be relationship, find by ids, bc what if 2 of these execute at the same time?
      @relationship.confirmed = false
      Notifier.delay.confirm_follow(@user, current_user)
      if @relationship.save
        respond_to do |format|
          format.html { redirect_to :back, notice: "Friend request sent to #{@user.name}" }
          format.js { render template: "relationships/create_no_reload" }
        end
      else
        redirect_to :back, notice: "Couldn't Friend #{@user.name}"
      end
    #OTHERWISE - IS NOT VENDOR AND DOES NOT REQUIRE CONFIMER FOLLOW
    else
      Notifier.delay.new_friend(@user, current_user)
      unless current_user.following?(@user) || current_user.request_following?(@user)
        current_user.follow!(@user)
      end
      @relationship = current_user.relationships.find_by_followed_id(@user.id)
      @relationship.confirmed = true
      if @relationship.save
        current_user.add_invitations_from_user(@user)
        @plan_counts = []
        @invite_counts = []
        @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
        @date = Time.now.in_time_zone(current_user.time_zone).to_date
        @event_suggestions = Suggestion.event_suggestions(current_user)
        @next_plan = current_user.plans.where("starts_at > ? and tipped = ?", Time.now, true).order("starts_at desc").last
        @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
        @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
        @vendor_friendships = current_user.vendor_friendships
        unless current_user.fb_user?
          @member_friends = current_user.fb_friends(session[:graph])[0]
          @friend_suggestions = @member_friends.reject { |mf| current_user.relationships.find_by_followed_id(mf.id) }
        end

        unless @user.following?(current_user) || @user.vendor?
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
          format.html { redirect_to :back, notice: "You are now friends with #{@user.name}" }
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
    current_user.delete_invitations_from_user(@user)
    @user.unfollow!(current_user)
    @user.delete_invitations_from_user(current_user)
    respond_to do |format|
      # @plan_counts = []
      # @invite_counts = []
      @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
      # @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
      # @date = Time.now.in_time_zone(current_user.time_zone)
      @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
      format.html { redirect_to :back, notice: "You are no longer friends with #{@follower.name} on hoos.in" }
      format.js
    end
  end

  def toggle
   @relationship = Relationship.find(params[:relationship_id])
   @relationship.toggle!
   @relationship.save
   respond_to do |format|
    format.html { redirect_to :back }
     @plan_counts = []
     @invite_counts = []
     @forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone), @plan_counts, @invite_counts)
     @date = Time.now.in_time_zone(current_user.time_zone)     
     @graph = session[:graph]
     format.js
   end
  end

  def ignore
    @relationship = Relationship.find(params[:relationship_id])
    @relationship.destroy

    respond_to do |format|
      @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
      @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
      format.html { redirect_to :back }
      format.js
    end
  end


  def confirm_and_follow
    @relationship = Relationship.find(params[:relationship_id])
    @relationship.confirm!
    @relationship.follower.add_invitations_from_user(@relationship.followed)
    @relationship.save
    unless current_user.following?(@relationship.follower) || current_user.vendor?
      unless current_user.request_following?(@relationship.follower)
        current_user.follow!(@relationship.follower)
      end
      @reverse_relationship = current_user.relationships.find_by_followed_id(@relationship.follower.id)
      @reverse_relationship.confirm!
      @reverse_relationship.save
      @reverse_relationship.follower.add_invitations_from_user(@relationship.followed)

    end
    respond_to do |format|
      @friendships = current_user.reverse_relationships.where('relationships.confirmed = true')
      #@forecastevents = current_user.forecast(Time.now.in_time_zone(current_user.time_zone))
      #@date = Time.now.in_time_zone(current_user.time_zone)
      @friend_requests = current_user.reverse_relationships.where('relationships.confirmed = false')
      @vendor_friendships = current_user.vendor_friendships
      format.html { redirect_to :back, notice: "You are now friends with #{@relationship.follower.name} on hoos.in" }
      format.js
    end
  end
end
