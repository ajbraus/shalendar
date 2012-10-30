class Api::V1::InvitationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
  	@mobile_user = User.find_by_id(params[:user_id])
  	@other_user = User.find_by_id(params[:other_user_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @other_user.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end
    @event = Event.find_by_id(params[:event_id])

    @mobile_user.invite!(@event, @other_user)

    render :json=> { :success => true,
    			:iid => @other_user.id
        }, :status=>200
  end

  def invite_all_friends

  	@mobile_user = User.find_by_id(params[:user_id])
    @event = Event.find(params[:event_id])
    if @mobile_user.nil?
      render :status=>400, :json=>{:error => "user was not found."}
    end
    if @event.nil?
      render :status=>400, :json=>{:error => "other user was not found."}
    end
    @mobile_user.invite_all_friends!(@event)
    render :status=>200, :json=> { :success => true} 
  end

end