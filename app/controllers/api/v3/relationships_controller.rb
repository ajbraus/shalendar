class Api::V3::RelationshipsController < ApplicationController
before_filter :authenticate_user!
respond_to :json

include UsersHelper

  def create
    @mobile_user = User.find_by_id(params[:user_id])
    @user_to_friend = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @user_to_follow.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @mobile_user.following?(@user_to_follow)
      render :status=>200, :json=>{ :followed_user=>@user_to_follow}
      return
    end
    @mobile_user.friend!(@user_to_follow)

    render :status=>200, :json=>{:success=>true, :fu=>@user_to_follow}
  end

  def destroy
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_ignore = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_ignore.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @mobile_user.ignore_inmate!(@other_user_to_ignore)

    render :json=>{:ignored_id=>@other_user_to_ignore.id}
  end

  def add_star
    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_star = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_star.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @mobile_user.friend!(@other_user_to_star)

    render :json=>{:starred_id=>@other_user_to_star.id}
  end

  def remove_star

    @mobile_user = User.find_by_id(params[:user_id])
    @other_user_to_star = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user_to_star.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end

    @mobile_user.unfriend!(@other_user_to_star)

    render :json=>{:unstarred_id=>@other_user_to_star.id}
  end

  def search_for_friends
    @found_users = User.search(params[:search_string])

    render json: @found_users
  end

  def search_for_fb_friends

    @graph = Koala::Facebook::API.new(params[:access_token]) 
    @found_users = current_user.fb_friends(@graph)[0]

    render json: @found_users.reject{|fu|current_user.following?(fu)}

  end

  def get_friends
    render json: {
      myself: current_user,
      friends: current_user.inmates | current_user.friends
      }
  end

  def get_profile
    @mobile_user = User.find_by_id(params[:user_id])
    @friend = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @friend.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end
    if @mobile_user.is_friended_by?(@friend)
      @events = @friend.ins 
    else
      @events = @friend.ins
      @events = @events.reject{ |e| e.friends_only? }
    end

        #For Light-weight events sending for list (but need guests to know if RSVPd)
    @list_events = []
    @events.each do |e|
      @guestids = []
      e.guests.each do |g|
        @guestids.push(g.id)
      end
      @instances = []
      if e.one_time?
        @i_guestids = []
        e.guests.each do |g|
          @i_guestids.push(g.id)
        end
        @instance = {
            :iid => e.id,
            :gids => @i_guestids,
            :start => e.starts_at,
            :end => e.ends_at,
            :address => e.address,
            :plan => @mobile_user.in?(e),
            :out => @mobile_user.out?(e),
            :host => e.user
        }
        @instances.push(@instance)
      end
      e.instances.each do |i|
        if i.ends_at > Time.zone.now
          @i_guestids = []
          i.guests.each do |g|
            @i_guestids.push(g.id)
          end
          @instance = {
            :iid => i.id,
            :gids => @i_guestids,
            :start => i.starts_at,
            :end => i.ends_at,
            :address => i.address,
            :plan => @mobile_user.in?(i),
            :out => @mobile_user.out?(i),
            :host => i.user
          }
          @instances.push(@instance)
        end
      end
      @temp = {
        :eid => e.id,
        :host => e.user,
        :title => e.title,  
        :image => e.image(:medium),
        :plan => @mobile_user.in?(e),
        :gids => @guestids,
        :instances => @instances,
        :ot => e.one_time
      }
      @list_events.push(@temp)
    end 
    render json: @list_events

  end
end
